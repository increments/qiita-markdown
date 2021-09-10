if ENV["CI"]
  require "codeclimate-test-reporter"

  module CodeClimate
    module TestReporter
      class Ci
        module GithubActions
          def service_data(env = ENV)
            puts "service_data"
            if env["GITHUB_ACTIONS"]
              {
                name:             "github-actions",
                build_identifier: env["GITHUB_JOB"],
                branch:           env["GITHUB_BRANCH"],
                commit_sha:       env["GITHUB_SHA"],
              }
            else
              super(env)
            end
          end
        end

        singleton_class.prepend GithubActions
      end
    end
  end

  CodeClimate::TestReporter.start
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
