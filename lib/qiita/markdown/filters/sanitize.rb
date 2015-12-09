module Qiita
  module Markdown
    module Filters
      # Sanitizes undesirable elements by whitelist-based rule.
      # You can pass optional :rule and :script context.
      class Sanitize < HTML::Pipeline::Filter
        # Wraps a node env to transform invalid node.
        class TransformableNode
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
            name == "li" && !node.ancestors.any? do |ancestor|
              %w[ol ul].include?(ancestor.name)
            end
          end

          def has_invalid_table_node?
            %w[thead tbody tfoot tr td th].include?(name) && !node.ancestors.any? do |ancestor|
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

        RULE = {
          attributes: {
            "a" => [
              "href",
            ],
            "iframe" => [
              "allowfullscreen",
              "frameborder",
              "height",
              "marginheight",
              "marginwidth",
              "scrolling",
              "src",
              "style",
              "width",
            ],
            "img" => [
              "src",
            ],
            "input" => [
              "checked",
              "disabled",
              "type",
            ],
            "div" => [
              "itemscope",
              "itemtype",
            ],
            "script" => [
              "async",
              "src",
              "type"
            ],
            "td" => [
              "style",
            ],
            "th" => [
              "style",
            ],
            "video" => [
              "src",
              "autoplay",
              "controls",
              "loop",
              "muted",
              "poster",
            ],
            all: [
              "abbr",
              "align",
              "alt",
              "border",
              "cellpadding",
              "cellspacing",
              "cite",
              "class",
              "color",
              "cols",
              "colspan",
              "data-lang",
              "datetime",
              "height",
              "hreflang",
              "id",
              "itemprop",
              "lang",
              "name",
              "rowspan",
              "tabindex",
              "target",
              "title",
              "width",
            ],
          },
          css: {
            properties: [
              "text-align",
            ],
          },
          elements: [
            "a",
            "b",
            "blockquote",
            "br",
            "code",
            "dd",
            "del",
            "div",
            "dl",
            "dt",
            "em",
            "font",
            "h1",
            "h2",
            "h3",
            "h4",
            "h5",
            "h6",
            "h7",
            "h8",
            "hr",
            "i",
            "img",
            "input",
            "ins",
            "kbd",
            "li",
            "ol",
            "p",
            "pre",
            "q",
            "rp",
            "rt",
            "ruby",
            "s",
            "samp",
            "span",
            "strike",
            "strong",
            "sub",
            "sup",
            "table",
            "tbody",
            "td",
            "tfoot",
            "th",
            "thead",
            "tr",
            "tt",
            "ul",
            "var",
          ],
          protocols: {
            "a" => {
              "href" => [
                :relative,
                "http",
                "https",
                "mailto",
              ],
            },
            "img" => {
              "src" => [
                :relative,
                "http",
                "https",
              ],
            },
            "video" => {
              "src" => [
                :relative,
                "http",
                "https",
              ],
              "poster" => [
                :relative,
                "http",
                "https",
              ],
            },
          },
          remove_contents: [
            "script",
          ],
          transformers: TransformableNode,
        }

        SCRIPTABLE_RULE = RULE.dup.tap do |rule|
          rule[:attributes] = RULE[:attributes].dup
          rule[:attributes][:all] = rule[:attributes][:all] + [:data]
          rule[:elements] = RULE[:elements] + ["iframe", "script", "video"]
          rule[:remove_contents] = []
        end

        def call
          ::Sanitize.clean_node!(doc, rule)
          doc
        end

        private

        def has_script_context?
          context[:script] == true
        end

        def rule
          case
          when context[:rule]
            context[:rule]
          when has_script_context?
            SCRIPTABLE_RULE
          else
            RULE
          end
        end
      end
    end
  end
end
