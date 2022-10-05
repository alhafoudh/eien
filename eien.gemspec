# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "eien/version"

Gem::Specification.new do |spec|
  spec.name = "eien"
  spec.version = Eien::VERSION
  spec.authors = ["Ahmed Al Hafoudh"]
  spec.email = ["alhafoudh@freevision.sk"]

  spec.summary = "A command line tool that helps you deploy and manage apps in Kubernetes"
  spec.description = spec.summary
  spec.homepage = "https://github.com/alhafoudh/eien"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/alhafoudh/eien"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    %x(git ls-files -z).split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Basics
  spec.add_development_dependency "bundler", "~> 2.3"
  spec.add_development_dependency "rake", "~> 13.0"

  # Common
  spec.add_dependency "activesupport", "~> 7.0"
  spec.add_dependency "dotiw", "~> 5.3"
  spec.add_dependency "httplog", "~> 1.6"
  spec.add_dependency "oj", "~> 3.13"
  spec.add_dependency "thor", "~> 1.2"
  spec.add_dependency "zeitwerk", "~> 2.6"

  # Kubernetes
  spec.add_dependency "krane", "~> 2.4"
  spec.add_dependency "kubeclient", "~> 4.10"

  # Utilities
  spec.add_dependency "colorize", "~> 0.8.0"
  spec.add_dependency "tty-prompt", "~> 0.23.1"
  spec.add_dependency "tty-table", "~> 0.12.0"

  # Debugging and analysis
  spec.add_development_dependency "fakefs", "~> 1.8"
  spec.add_development_dependency "pry", "~> 0.14.1"
  spec.add_development_dependency "rspec", "~> 3.11"
  spec.add_development_dependency "rubocop", "~> 1.36"
  spec.add_development_dependency "rubocop-rspec", "~> 2.13"
  spec.add_development_dependency "rubocop-shopify", "~> 1.0.5"
  spec.add_development_dependency "simplecov", "~> 0.21.2"
end
