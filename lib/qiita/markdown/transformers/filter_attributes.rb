# frozen_string_literal: true

module Qiita
  module Markdown
    module Transformers
      class FilterAttributes
        FILTERS = {
          "a" => {
            "class" => %w[autolink],
            "rel" => %w[footnote url],
            "rev" => %w[footnote],
            "id" => /\Afnref-.+\z/,
          },
          "blockquote" => {
            "class" => Embed::Tweet::CLASS_NAME,
          },
          "div" => {
            "class" => %w[footnotes],
          },
          "p" => {
            "class" => Embed::CodePen::CLASS_NAME,
          },
          "section" => {
            "class" => %w[footnotes],
          },
          "sup" => {
            "id" => /\Afnref\d+\z/,
          },
          "li" => {
            "id" => /\Afn.+\z/,
          },
        }.freeze

        DELIMITER = " "

        def self.call(**args)
          new(**args).transform
        end

        def initialize(env)
          @env = env
        end

        def transform
          return unless FILTERS.key?(name)

          FILTERS[name].each_pair do |attr, pattern|
            filter_attribute(attr, pattern) if node.attributes.key?(attr)
          end
        end

        private

        def filter_attribute(attr, pattern)
          node[attr] = node[attr].split(DELIMITER).select do |value|
            pattern.is_a?(Array) ? pattern.include?(value) : (pattern =~ value)
          end.join(DELIMITER)
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
