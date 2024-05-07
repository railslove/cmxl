lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cmxl/version'

Gem::Specification.new do |spec|
  spec.name          = 'cmxl'
  spec.version       = Cmxl::VERSION
  spec.authors       = ['Michael Bumann']
  spec.email         = ['michael@railslove.com']
  spec.summary       = 'Cmxl is your friendly MT940 bank statement parser'
  spec.description   = 'Cmxl provides an friendly, extensible and customizable parser for the MT940 bank statement format.'
  spec.homepage      = 'https://github.com/railslove/cmxl'
  spec.license       = 'MIT'

  spec.post_install_message = "Thanks for using Cmxl - your friendly MT940 parser!\nWe hope we can make dealing with MT940 files a bit more fun. :) \nPlease create an issue on github if anything is not as expected.\n\n"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~>3.0'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'byebug'

  spec.add_dependency 'rchardet'
end
