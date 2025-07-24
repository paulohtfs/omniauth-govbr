# frozen_string_literal: true

require_relative "lib/omniauth/govbr/version"

Gem::Specification.new do |spec|
  spec.name = "omniauth-govbr"
  spec.version = Omniauth::Govbr::VERSION
  spec.authors = ["Paulo Tada"]
  spec.email = ["paulohtfs@gmail.com"]

  spec.summary = "Unofficial OmniAuth OAuth2 for GovBR"
  spec.description = "Implementing OmniAuth OAuth2 strategy for GovBR"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"
  spec.homepage = "https://participa.gov.br"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/paulohtfs/omniauth-govbr"
  spec.metadata["changelog_uri"] = "https://github.com/paulohtfs/omniauth-govbr/tags"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "omniauth", "~> 2.1"
  spec.add_dependency "omniauth-oauth2", "~> 1.1"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
