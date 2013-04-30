$:.push File.expand_path("../lib", __FILE__)

# The gem's version:
require "respect/version"

Gem::Specification.new do |s|
  s.name        = "respect"
  s.version     = Respect::VERSION
  s.authors     = ["Nicolas Despres"]
  s.email       = ["nicolas.despres@gmail.com"]
  s.summary     = "JSON schema definition using a Ruby DSL."
  s.description = "Respect allow to specify JSON schema using a Ruby DSL. It also provides a validator a sanitizer and dumper to generate json-schema.org compliant spec."

  s.files = Dir["lib/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md", "STATUS_MATRIX.html", "RELATED_WORK.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "json", "~> 1.7.7"
  s.add_dependency "activesupport", "~> 3.2.13"

  s.add_development_dependency 'yard', '~> 0.8.5.2'
  s.add_development_dependency 'mocha', '~> 0.13.3'
  s.add_development_dependency 'rake', '~> 10.0.4'
  s.add_development_dependency 'redcarpet', '~> 2.2.2'
end
