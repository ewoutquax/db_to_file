# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'db_to_file/version'
Gem::Specification.new do |spec|
  spec.name          = "db_to_file"
  spec.version       = DbToFile::VERSION
  spec.authors       = ["Ewout Quax"]
  spec.email         = ["ewout.quax@quicknet.nl"]
  spec.summary       = %q{Unload and upload database-tables to a file-system}
  spec.description   = %q{Unload and upload database-tables to a file-system}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'activerecord', '> 4.0.0'
  spec.add_dependency 'activesupport', '> 4.0.0'
  spec.add_dependency 'git', '> 1.2.6'

  spec.add_development_dependency 'bundler', '~> 1.5'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency "minitest", "~> 4.7.3"
  spec.add_development_dependency "mocha"
  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency 'turn'
  spec.add_development_dependency 'simplecov'
end
