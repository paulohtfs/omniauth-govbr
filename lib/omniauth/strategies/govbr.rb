# frozen_string_literal: true

require "securerandom"
require "omniauth-oauth2"

module OmniAuth
  module Strategies
    # OmniAuth strategy for gov.br login (OpenID Connect authorization code flow with PKCE).
    class Govbr < OmniAuth::Strategies::OAuth2
      PRODUCTION_SITE = "https://sso.acesso.gov.br"
      STAGING_SITE = "https://sso.staging.acesso.gov.br"
      DEFAULT_SCOPE = "openid email profile"
      NONCE_SESSION_KEY = "omniauth.govbr.nonce"

      option :name, "govbr"
      option :pkce, true
      option :scope, DEFAULT_SCOPE
      option :client_options, {
        site: PRODUCTION_SITE,
        authorize_url: "/authorize",
        token_url: "/token",
        user_info_url: "/userinfo"
      }

      uid { raw_info["sub"] }

      info do
        {
          sub: raw_info["sub"],
          name: raw_info["name"],
          nickname: nickname,
          email: raw_info["email"],
          phone: raw_info["phone_number"],
          cpf: cpf
        }
      end

      extra do
        { raw_info: raw_info }
      end

      # gov.br requires a nonce on the authorization request to bind the session to the ID token.
      def authorize_params
        super.tap do |params|
          params[:nonce] ||= SecureRandom.hex(16)
          session[NONCE_SESSION_KEY] = params[:nonce]
        end
      end

      def raw_info
        @raw_info ||= access_token.get(options.client_options[:user_info_url]).parsed || {}
      end

      def callback_url
        full_host + callback_path
      end

      # gov.br returns the user's CPF as the OpenID Connect subject.
      def cpf
        raw_info["sub"]&.gsub(/\D/, "")
      end

      def nickname
        name = raw_info["name"].to_s.strip
        return if name.empty?

        name.split.join("_").downcase
      end
    end
  end
end
