if ENV["CI"]
  require "simplecov"
  require "simplecov_json_formatter"
  SimpleCov.start do
    formatter SimpleCov::Formatter::MultiFormatter.new([
                                                         SimpleCov::Formatter::JSONFormatter,
                                                         SimpleCov::Formatter::HTMLFormatter,
                                                       ])
    add_filter "/spec/"
  end
end

require "qiita-markdown"

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.default_formatter = "doc"
  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  config.example_status_persistence_file_path = "spec/examples.txt"
end
