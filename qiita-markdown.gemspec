lib = File.expand_path("lib", __dir__)
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
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 3.0.0"

  spec.add_dependency "addressable"
  spec.add_dependency "gemoji"
  spec.add_dependency "github-linguist", ">= 7", "< 10"
  spec.add_dependency "html-pipeline", "~> 2.0"
  spec.add_dependency "mem"
  spec.add_dependency "qiita_marker", "~> 0.23.9"
  spec.add_dependency "rouge", "~> 4.2"
  spec.add_dependency "sanitize"
  spec.add_dependency "uri", ">= 1.0.4"
  spec.metadata["rubygems_mfa_required"] = "true"
end
