# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'delta/version'

Gem::Specification.new do |spec|
  spec.name          = "delta"
  spec.version       = Delta::VERSION
  spec.authors       = ["Theodore Konukhov"]
  spec.email         = ["me@thdr.io"]

  spec.summary       = %q{Deltas for ActiveRecord models}
  spec.description   = %q{Deltas for ActiveRecord models}
  spec.homepage      = "https://github.com/konukhov/delta"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency     "request_store"

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "awesome_print"
  spec.add_development_dependency "rails", "~> 4.2"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency "test_after_commit"
  spec.add_development_dependency "pg"
end
