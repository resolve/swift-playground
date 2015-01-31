# Ensure we require the local version and not one we might have installed already
require File.join([File.dirname(__FILE__), 'lib', 'swift', 'playground', 'metadata.rb'])
spec = Gem::Specification.new do |s|
  s.name          = 'swift-playground'
  s.version       = Swift::Playground::VERSION
  s.authors       = ['Mark Haylock']
  s.email         = ['mark@resolvedigital.co.nz']
  s.homepage      = ''
  s.license       = 'MIT'
  s.summary       = Swift::Playground::SUMMARY

  s.files         = `git ls-files -z`.split("\x0")
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ['lib']

  s.required_ruby_version = '>= 1.9.3'

  s.add_runtime_dependency 'html-pipeline', '~> 1.11.0'
  s.add_runtime_dependency 'activesupport', '~> 4.1.6'
  s.add_runtime_dependency 'github-markdown', '~> 0.6.7'
  s.add_runtime_dependency 'sanitize', '~> 3.0.3'
  s.add_runtime_dependency 'gemoji', '~> 2.1.0'
  s.add_runtime_dependency 'gli', '~> 2.12.2'
  s.add_runtime_dependency 'paint', '~> 0.9.0'
  s.add_runtime_dependency 'highline', '~> 1.6.21'
end
