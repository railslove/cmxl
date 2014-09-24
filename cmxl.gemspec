# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cmxl/version'

Gem::Specification.new do |spec|
  spec.name          = "cmxl"
  spec.version       = Cmxl::VERSION
  spec.authors       = ["Michael Bumann"]
  spec.email         = ["michael@railslove.com"]
  spec.summary       = %q{Cmxl is your friendly MT940 bank statement parser}
  spec.description   = %q{Cmxl provides an extensible and customizable parser for the MT940 bank statement format.}
  spec.homepage      = "http://railslove.com"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", '~>3.0'
end
