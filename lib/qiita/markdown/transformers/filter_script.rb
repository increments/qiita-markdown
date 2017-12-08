module Qiita
  module Markdown
    module Transformers
      class FilterScript
        WHITE_LIST = [
          CodePen::SCRIPT_URL,
          Tweet::SCRIPT_URL,
        ].freeze

        def self.call(*args)
          new(*args).transform
        end

        def initialize(env)
          @env = env
        end

        def transform
          if name == "script"
            if WHITE_LIST.include?(node["src"])
              node["async"] = "async" unless node.attributes.key?("async")
              node.children.unlink
            else
              node.unlink
            end
          end
        end

        private

        def name
          @env[:node_name]
        end

        def node
          @env[:node]
        end
      end
    end
  end
end
