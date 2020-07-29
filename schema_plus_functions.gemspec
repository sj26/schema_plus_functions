# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'schema_plus/functions/version'

Gem::Specification.new do |gem|
  gem.name          = "schema_plus_functions"
  gem.version       = SchemaPlus::Functions::VERSION
  gem.authors       = ["Edward Rudd"]
  gem.email         = ["urkle@outoforder.cc"]
  gem.summary       = %q{Adds support for functions in ActiveRecord}
  gem.description   = %q{Adds support for functions in ActiveRecord}
  gem.homepage      = "https://github.com/SchemaPlus/schema_plus_functions"
  gem.license       = "MIT"

  gem.files         = `git ls-files -z`.split("\x0")
  gem.executables   = gem.files.grep(%r{^bin/}) { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "activerecord", ">= 5.2", "< 5.3"
  gem.add_dependency "schema_plus_core"

  gem.add_development_dependency "bundler"
  gem.add_development_dependency "rake", "~> 10.0"
  gem.add_development_dependency "rspec", "~> 3.0"
  gem.add_development_dependency "schema_dev", "~> 3.11", ">= 3.11.1"
  gem.add_development_dependency "simplecov"
  gem.add_development_dependency "simplecov-gem-profile"
end
