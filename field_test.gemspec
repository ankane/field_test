
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "field_test/version"

Gem::Specification.new do |spec|
  spec.name          = "field_test"
  spec.version       = FieldTest::VERSION
  spec.summary       = "A/B testing for Rails"
  spec.homepage      = "https://github.com/ankane/field_test"
  spec.license       = "MIT"

  spec.author        = "Andrew Kane"
  spec.email         = "andrew@chartkick.com"

  spec.files         = Dir["*.{md,txt}", "{app,config,lib}/**/*"]
  spec.require_path  = "lib"

  spec.required_ruby_version = ">= 2.4"

  spec.add_dependency "railties", ">= 5"
  spec.add_dependency "activerecord", ">= 5"
  spec.add_dependency "distribution"
  spec.add_dependency "browser", "~> 2.0"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "combustion"
  spec.add_development_dependency "rails"
  spec.add_development_dependency "sqlite3", "~> 1.3.0"
end
