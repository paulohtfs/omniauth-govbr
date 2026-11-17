<div align="center">
  <img src="docs/lablivre-logo.png" alt="Lab Livre" width="360">
</div>

# OmniAuth gov.br

**English** | [Português (Brasil)](README.pt-BR.md)

[![pipeline status](https://gitlab.com/lappis-unb/decidimbr/components-brasil-participativo/omniauth-govbr/badges/main/pipeline.svg)](https://gitlab.com/lappis-unb/decidimbr/components-brasil-participativo/omniauth-govbr/-/commits/main)
[![Gem Version](https://badge.fury.io/rb/omniauth-govbr.svg)](https://rubygems.org/gems/omniauth-govbr)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE.txt)

Unofficial OmniAuth OAuth2 strategy for gov.br login.

`omniauth-govbr` lets any Rack or Rails application sign users in with their gov.br account, the single sign-on
service of the Brazilian federal government (Login Único). It implements the OpenID Connect authorization code flow
with PKCE against `sso.acesso.gov.br` and turns the gov.br user info into a standard OmniAuth auth hash. It is built
for Brazilian federal deployments such as the Brasil Participativo platform, and your application must be registered
with gov.br to obtain a client ID and secret.

> **Unofficial.** This project is not affiliated with or endorsed by the Brazilian federal government or the gov.br
> team (Secretaria de Governo Digital).

## Table of contents

- [Features](#features)
- [Compatibility](#compatibility)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
- [Privacy and data](#privacy-and-data)
- [Development](#development)
- [Contributing](#contributing)
- [Security](#security)
- [Maintainers](#maintainers)
- [License](#license)

## Features

- Sign in with gov.br through the standard OmniAuth `/auth/govbr` flow.
- Authorization code flow with PKCE enabled by default.
- Auth hash with the user's CPF (as `uid`), name, email and a generated nickname.
- Works against both the gov.br production and staging environments.

## Compatibility

| omniauth-govbr | OmniAuth | Ruby |
|---|---|---|
| 0.1.x | OmniAuth 2.x, omniauth-oauth2 1.8+ | >= 3.0 |

## Installation

```bash
bundle add omniauth-govbr
```

## Configuration

Register the provider in an initializer, for example `config/initializers/omniauth.rb`:

```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :govbr, ENV["GOVBR_CLIENT_ID"], ENV["GOVBR_CLIENT_SECRET"],
           scope: "openid email profile",
           client_options: { site: ENV.fetch("GOVBR_SITE", "https://sso.acesso.gov.br") }
end
```

| Setting | Default | Description |
|---|---|---|
| `scope` | none | Space-separated gov.br scopes. Use `openid email profile`; add `govbr_confiabilidades` to read the account trust levels. |
| `pkce` | `true` | Sends a PKCE code challenge, as required by gov.br. |
| `client_options[:site]` | `https://sso.staging.acesso.gov.br` | gov.br SSO host. Set `https://sso.acesso.gov.br` in production. |
| `client_options[:authorize_url]` | `/authorize` | Authorization endpoint path. |
| `client_options[:token_url]` | `/token` | Token endpoint path. |
| `client_options[:user_info_url]` | `/userinfo` | User info endpoint path. |

The gem reads no environment variables itself. The variables below are only the names used in the example above.

| Environment variable | Required | Description |
|---|---|---|
| `GOVBR_CLIENT_ID` | yes | Client ID issued by gov.br for your application. |
| `GOVBR_CLIENT_SECRET` | yes | Client secret issued by gov.br for your application. |
| `GOVBR_SITE` | no | gov.br SSO host, for example `https://sso.staging.acesso.gov.br` while testing. |

The redirect URI registered with gov.br must be `https://<your-host>/auth/govbr/callback`.

## Usage

Send the user to `/auth/govbr` with a POST request (OmniAuth 2 blocks GET by default):

```erb
<%= button_to "Sign in with gov.br", "/auth/govbr", method: :post, data: { turbo: false } %>
```

After login, gov.br redirects to `/auth/govbr/callback` and `request.env["omniauth.auth"]` holds:

```ruby
{
  provider: "govbr",
  uid: "12345678900",               # gov.br "sub", the user's CPF
  info: {
    sub: "12345678900",
    name: "Maria da Silva",
    nickname: "maria_da_silva",     # name, lower case, spaces replaced by "_"
    email: "maria@example.com",
    locale: nil,
    cpf: "12345678900"              # digits only
  },
  credentials: { token: "...", expires_at: 1_700_000_000, expires: true },
  extra: { raw_info: { ... } }      # full response of the /userinfo endpoint
}
```

## Privacy and data

The gem stores nothing. On each login it receives personal data from gov.br and passes it to the host application
in the auth hash: CPF (`uid`, `info.sub`, `info.cpf`), full name, email, and everything else the `/userinfo` endpoint
returns in `extra.raw_info` (for example phone number and profile picture, depending on the granted scopes). The CPF
is personal data under the LGPD (Lei nº 13.709/2018). The host application decides what to keep, for how long, and
on which legal basis; store only what you need.

## Development

```bash
bin/setup
bundle exec rake   # tests + rubocop
```

## Contributing

Contributions are welcome. Read [CONTRIBUTING.md](CONTRIBUTING.md) before opening a merge request. It covers the
development setup, the commit convention, the language policy (English for code, commits and merge requests;
UI strings in both `en` and `pt-BR`), and the checks that must pass.

Bugs and feature ideas go in the [issue tracker](https://gitlab.com/lappis-unb/decidimbr/components-brasil-participativo/omniauth-govbr/-/issues).
This project follows the [Code of Conduct](CODE_OF_CONDUCT.md).

## Security

**Don't report vulnerabilities in public issues.** See [SECURITY.md](SECURITY.md) for supported versions and how to report
privately (GitLab confidential issue or TODO-TEAM-EMAIL).

## Maintainers

Maintained by [LAPPIS — Universidade de Brasília](https://lappis.rocks) for the Brasil Participativo platform.

- Paulo Tada (TODO-GITLAB-HANDLE)
- TODO-MAINTAINER-2

See [CHANGELOG.md](CHANGELOG.md) for release history.

## License

Available as open source under the terms of the [MIT License](LICENSE.txt).
