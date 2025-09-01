require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Govbr < OmniAuth::Strategies::OAuth2
      SCOPES = %i(openid email profile govbr_confiabilidades)

      option :name, 'govbr'
      option :pkce, true
      option :grant_type, 'authorization_code'
      option :client_options, {
        site: 'https://sso.staging.acesso.gov.br',
        authorize_url: '/authorize',
        token_url: '/token',
        user_info_url: '/userinfo'
      }

      uid { raw_info['sub'] }

      info do
        {
          sub: raw_info['sub'],
          name: raw_info['name'],
          nickname: nickname,
          email: raw_info['email'],
          locale: raw_info['locale']
        }
      end

      extra do
        { raw_info: raw_info }
      end

      def raw_info
        @_raw_info ||= access_token.get(options.client_options['user_info_url']).parsed || {}
      end

      def callback_url
        full_host + callback_path
      end

      def nickname
        @_nickname ||= raw_info['name'].gsub(' ', '_').downcase
      end
    end
  end
end
