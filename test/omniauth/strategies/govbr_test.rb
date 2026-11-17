# frozen_string_literal: true

require "test_helper"
require "rack"

module OmniAuth
  module Strategies
    class GovbrTest < ::Test::Unit::TestCase
      RAW_INFO = {
        "sub" => "12345678900",
        "name" => "Maria da Silva",
        "email" => "maria@example.com"
      }.freeze

      def strategy(raw_info = RAW_INFO)
        app = ->(_env) { [200, {}, ["OK"]] }
        OmniAuth::Strategies::Govbr.new(app, "client-id", "client-secret").tap do |s|
          s.define_singleton_method(:raw_info) { raw_info }
        end
      end

      test "is registered as govbr" do
        assert_equal("govbr", strategy.options.name)
      end

      test "enables PKCE" do
        assert_true(strategy.options.pkce)
      end

      test "points to the gov.br endpoints" do
        client_options = strategy.options.client_options

        assert_equal("/authorize", client_options.authorize_url)
        assert_equal("/token", client_options.token_url)
        assert_equal("/userinfo", client_options.user_info_url)
      end

      test "uses sub as uid" do
        assert_equal("12345678900", strategy.uid)
      end

      test "maps user info" do
        info = strategy.info

        assert_equal("12345678900", info[:sub])
        assert_equal("Maria da Silva", info[:name])
        assert_equal("maria@example.com", info[:email])
      end

      test "builds nickname from name" do
        assert_equal("maria_da_silva", strategy.nickname)
      end

      test "exposes raw info in extra" do
        assert_equal(RAW_INFO, strategy.extra[:raw_info])
      end

      test "callback_url has no query string" do
        s = strategy
        env = Rack::MockRequest.env_for("https://example.com/auth/govbr/callback?code=abc&state=xyz")
        s.instance_variable_set(:@env, env)

        assert_equal("https://example.com/auth/govbr/callback", s.callback_url)
      end
    end
  end
end
