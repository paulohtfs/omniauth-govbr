# frozen_string_literal: true

require "test_helper"
require "rack"

class GovbrStrategyTest < Test::Unit::TestCase
  RAW_INFO = {
    "sub" => "12345678900",
    "name" => "Maria da Silva",
    "email" => "maria@example.com",
    "phone_number" => "61999999999"
  }.freeze

  def build_strategy(**options)
    app = ->(_env) { [200, {}, ["OK"]] }
    OmniAuth::Strategies::Govbr.new(app, "client-id", "client-secret", **options)
  end

  def strategy(raw_info = RAW_INFO)
    build_strategy.tap do |s|
      s.define_singleton_method(:raw_info) { raw_info }
    end
  end

  def with_env(strategy, url = "https://example.com/auth/govbr")
    env = Rack::MockRequest.env_for(url)
    env["rack.session"] = {}
    strategy.instance_variable_set(:@env, env)
    strategy
  end

  test "is registered as govbr" do
    assert_equal("govbr", build_strategy.options.name)
  end

  test "enables PKCE" do
    assert_true(build_strategy.options.pkce)
  end

  test "defaults to the gov.br production site" do
    assert_equal("https://sso.acesso.gov.br", build_strategy.options.client_options.site)
  end

  test "allows the staging site" do
    s = build_strategy(client_options: { site: OmniAuth::Strategies::Govbr::STAGING_SITE })

    assert_equal("https://sso.staging.acesso.gov.br", s.options.client_options.site)
    assert_equal("/authorize", s.options.client_options.authorize_url)
  end

  test "points to the gov.br endpoints" do
    client_options = build_strategy.options.client_options

    assert_equal("/authorize", client_options.authorize_url)
    assert_equal("/token", client_options.token_url)
    assert_equal("/userinfo", client_options.user_info_url)
  end

  test "requests openid email profile by default" do
    params = with_env(build_strategy).authorize_params

    assert_equal("openid email profile", params[:scope])
  end

  test "allows a custom scope" do
    params = with_env(build_strategy(scope: "openid govbr_confiabilidades")).authorize_params

    assert_equal("openid govbr_confiabilidades", params[:scope])
  end

  test "sends a nonce and keeps it in the session" do
    s = with_env(build_strategy)
    params = s.authorize_params

    assert_match(/\A\h{32}\z/, params[:nonce])
    assert_equal(params[:nonce], s.session["omniauth.govbr.nonce"])
  end

  test "sends a new nonce on each request" do
    first = with_env(build_strategy).authorize_params[:nonce]
    second = with_env(build_strategy).authorize_params[:nonce]

    assert_not_equal(first, second)
  end

  test "uses sub as uid" do
    assert_equal("12345678900", strategy.uid)
  end

  test "maps user info" do
    info = strategy.info

    assert_equal("12345678900", info[:sub])
    assert_equal("Maria da Silva", info[:name])
    assert_equal("maria@example.com", info[:email])
    assert_equal("61999999999", info[:phone])
  end

  test "takes the cpf from sub" do
    assert_equal("12345678900", strategy.info[:cpf])
  end

  test "keeps only digits in the cpf" do
    assert_equal("12345678900", strategy(RAW_INFO.merge("sub" => "123.456.789-00")).info[:cpf])
  end

  test "returns nil cpf when sub is missing" do
    assert_nil(strategy({}).info[:cpf])
  end

  test "builds nickname from name" do
    assert_equal("maria_da_silva", strategy.nickname)
  end

  test "collapses repeated spaces in nickname" do
    assert_equal("maria_da_silva", strategy(RAW_INFO.merge("name" => "  Maria  da Silva ")).nickname)
  end

  test "returns nil nickname when name is missing" do
    assert_nil(strategy(RAW_INFO.except("name")).nickname)
  end

  test "returns nil nickname when name is blank" do
    assert_nil(strategy(RAW_INFO.merge("name" => "  ")).nickname)
  end

  test "exposes raw info in extra" do
    assert_equal(RAW_INFO, strategy.extra[:raw_info])
  end

  test "fetches raw info from the userinfo endpoint" do
    response = Struct.new(:parsed).new(RAW_INFO)
    token = Object.new
    requested = []
    token.define_singleton_method(:get) do |path|
      requested << path
      response
    end
    s = build_strategy
    s.define_singleton_method(:access_token) { token }

    assert_equal(RAW_INFO, s.raw_info)
    assert_equal(["/userinfo"], requested)
  end

  test "returns empty raw info when userinfo has no body" do
    token = Object.new
    token.define_singleton_method(:get) { |_path| Struct.new(:parsed).new(nil) }
    s = build_strategy
    s.define_singleton_method(:access_token) { token }

    assert_equal({}, s.raw_info)
  end

  test "callback_url has no query string" do
    s = with_env(strategy, "https://example.com/auth/govbr/callback?code=abc&state=xyz")

    assert_equal("https://example.com/auth/govbr/callback", s.callback_url)
  end
end
