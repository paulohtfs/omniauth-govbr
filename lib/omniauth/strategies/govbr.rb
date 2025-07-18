require "omniauth-oauth2"

module OmniAuth
  module Strategies
    class Govbr < OmniAuth::Strategies::OAuth2
      SCOPES = %i(openid email profile govbr_confiabilidades)

      option :name, "govbr"
      option :client_options, {
        site: "https://sso.staging.acesso.gov.br",
        authorize_url: "https://sso.staging.acesso.gov.br/authorize",
        token_url: "https://sso.staging.acesso.gov.br/token",
        user_info_url: "https://sso.staging.acesso.gov.br/userinfo/"
      }

      uid { raw_info["sub"].to_s }

      info do
        {
          sub: raw_info['sub'],
          name: raw_info['name'],
          social_name: raw_info['social_name'],
          profile: "https://servicos.staging.acesso.gov.br/",
          email: raw_info['email'],
          email_verified: raw_info['email_verified'],
          phone_number: raw_info['phone_number'],
          phone_number_verified: raw_info['phone_number_verified']
        }
      end

      extra do
        { raw_info: raw_info }
      end

      def raw_info
        @_raw_info ||= access_token.get(client_options.fetch(:user_info_url)).parsed || {}
      end
    end
  end
end
