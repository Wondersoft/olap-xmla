# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'olap/xmla/version'

Gem::Specification.new do |spec|
  spec.name          = "olap-xmla"
  spec.version       = Olap::Xmla::VERSION
  spec.authors       = ["studnev"]
  spec.email         = ["aleksey@wondersoft.ru"]
  spec.summary       = %q{OLAP XMLA gem}
  spec.description   = %q{Pure Ruby gem to make MDX queries on OLAP databases using XMLA connection. Can be used with any XMLA-compliant server, like Olaper or Mondrian.}
  spec.homepage      = "https://github.com/Wondersoft/olap-xmla"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_runtime_dependency 'savon', '~> 2.5.1'
end
