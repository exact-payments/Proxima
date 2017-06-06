# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'proxima/version'

Gem::Specification.new do |spec|
  spec.name          = "proxima"
  spec.version       = Proxima::VERSION
  spec.authors       = ["Robert Hurst"]
  spec.email         = ["robertwhurst@gmail.com"]

  spec.summary       = "REST Models for Ruby on Rails"
  spec.description   = "Proxima is a gem the provides models for use with REST endpoints. These models are based upon the Active Model interface"
  spec.homepage      = "https://github.com/fintechdev/proxima"
  spec.license       = "MIT"

  spec.files         = Dir['lib/**/*.rb']
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.5"

  spec.add_dependency "activemodel", '~> 4.0', '>= 4.0.0'
end
