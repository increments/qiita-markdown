module Qiita
  module Markdown
    module Filters
      # Sanitizes user input if :strict context is given.
      class UserInputSanitizer < HTML::Pipeline::Filter
        class AttributeFilter
          FILTERS = {
            "a" => {
              "class" => %w[autolink],
              "rel" => %w[footnote url],
              "rev" => %w[footnote],
            },
            "div" => {
              "class" => %w[footnotes],
            },
            "sup" => {
              "id" => /\Afnref\d+\z/,
            },
            "li" => {
              "id" => /\Afn\d+\z/,
            },
          }.freeze

          DELIMITER = " ".freeze

          def self.call(*args)
            new(*args).transform
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

        RULE = {
          elements: %w[
            a b blockquote br code dd del details div dl dt em font h1 h2 h3 h4 h5 h6
            hr i img input ins kbd li ol p pre q rp rt ruby s samp strike strong sub
            summary sup table tbody td tfoot th thead tr ul var
          ],
          attributes: {
            "a"          => %w[class href rel title],
            "blockquote" => %w[cite],
            "code"       => %w[data-metadata],
            "div"        => %w[class],
            "font"       => %w[color],
            "h1"         => %w[id],
            "h2"         => %w[id],
            "h3"         => %w[id],
            "h4"         => %w[id],
            "h5"         => %w[id],
            "h6"         => %w[id],
            "img"        => %w[alt height src title width],
            "ins"        => %w[cite datetime],
            "li"         => %w[id],
            "q"          => %w[cite],
            "sup"        => %w[id],
            "td"         => %w[colspan rowspan style],
            "th"         => %w[colspan rowspan style],
          },
          protocols: {
            "a"          => { "href" => ["http", "https", "mailto", :relative] },
            "blockquote" => { "cite" => ["http", "https", :relative] },
            "q"          => { "cite" => ["http", "https", :relative] },
          },
          css: {
            properties: %w[text-align],
          },
          remove_contents: %w[
            script
          ],
          transformers: AttributeFilter,
        }.freeze

        def call
          ::Sanitize.clean_node!(doc, RULE) if context[:strict]
          doc
        end
      end
    end
  end
end
