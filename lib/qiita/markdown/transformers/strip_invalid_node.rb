module Qiita
  module Markdown
    module Transformers
      # Wraps a node env to transform invalid node.
      class StripInvalidNode
        def self.call(*args)
          new(*args).transform
        end

        def initialize(env)
          @env = env
        end

        def transform
          if has_invalid_list_node? || has_invalid_table_node?
            node.replace(node.children)
          end
        end

        private

        def has_invalid_list_node?
          name == "li" && node.ancestors.none? do |ancestor|
            %w[ol ul].include?(ancestor.name)
          end
        end

        def has_invalid_table_node?
          %w[thead tbody tfoot tr td th].include?(name) && node.ancestors.none? do |ancestor|
            ancestor.name == "table"
          end
        end

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
