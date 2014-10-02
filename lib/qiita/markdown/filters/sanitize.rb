module Qiita
  module Markdown
    module Filters
      # Sanitizes undesirable elements by whitelist-based rule.
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
            "img" => [
              "src",
            ],
            "div" => [
              "itemscope",
              "itemtype",
            ],
            all: [
              "abbr",
              "accept-charset",
              "accept",
              "accesskey",
              "action",
              "align",
              "alt",
              "axis",
              "border",
              "cellpadding",
              "cellspacing",
              "char",
              "charoff",
              "charset",
              "checked",
              "cite",
              "clear",
              "color",
              "cols",
              "colspan",
              "compact",
              "coords",
              "datetime",
              "details",
              "dir",
              "disabled",
              "enctype",
              "for",
              "frame",
              "headers",
              "height",
              "hreflang",
              "hspace",
              "ismap",
              "itemprop",
              "label",
              "lang",
              "longdesc",
              "maxlength",
              "media",
              "method",
              "multiple",
              "name",
              "nohref",
              "noshade",
              "nowrap",
              "prompt",
              "readonly",
              "rel",
              "rev",
              "rows",
              "rowspan",
              "rules",
              "scope",
              "selected",
              "shape",
              "size",
              "span",
              "start",
              "summary",
              "tabindex",
              "target",
              "title",
              "type",
              "usemap",
              "valign",
              "value",
              "vspace",
              "width",
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
              ],
            },
            "img" => {
              "src" => [
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

        def call
          ::Sanitize.clean_node!(doc, rule)
          doc
        end

        private

        def rule
          context[:rule] || RULE
        end
      end
    end
  end
end
