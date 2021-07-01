lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "qiita/markdown/version"

Gem::Specification.new do |spec|
  spec.name          = "qiita-markdown"
  spec.version       = Qiita::Markdown::VERSION
  spec.authors       = ["Ryo Nakamura"]
  spec.email         = ["r7kamura@gmail.com"]
  spec.summary       = "Qiita-specified markdown processor."
  spec.homepage      = "https://github.com/increments/qiita-markdown"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.2.0"

  spec.add_dependency "gemoji"
  spec.add_dependency "github-linguist", "~> 4.0"
  spec.add_dependency "html-pipeline", "~> 2.0"
  spec.add_dependency "mem"
  spec.add_dependency "pygments.rb", "~> 1.0"
  spec.add_dependency "greenmat", "3.5.1.2"
  spec.add_dependency "sanitize"
  spec.add_dependency "addressable"
  spec.add_development_dependency "activesupport", "4.2.6"
  spec.add_development_dependency "benchmark-ips", "~> 1.2"
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "codeclimate-test-reporter", "0.4.4"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.1"
  spec.add_development_dependency "rubocop", "0.49.1"
end
