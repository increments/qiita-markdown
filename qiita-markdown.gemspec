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

  spec.add_dependency "activesupport"
  spec.add_dependency "gemoji"
  spec.add_dependency "github-linguist"
  spec.add_dependency "html-pipeline"
  spec.add_dependency "mem"
  spec.add_dependency "redcarpet"
  spec.add_dependency "rugged", ">= 0.21.1b2"
  spec.add_dependency "sanitize"
  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "3.1.0"
end
