module Qiita
  module Markdown
    module Filters
      class InlineCodeColor < HTML::Pipeline::Filter
        DEFAULT_CLASS_NAME = "inline-code-color".freeze

        REGEXPS = Regexp.union(
          /\#(?:\h{3}|\h{6})/,
          /rgba?\(\s*(?:\d+(?:\,|\s)\s*){2}\d+\s*\)/,
          /rgba?\(\s*(?:\d+%(?:\,|\s)\s*){2}\d+%\s*\)/,
          /rgba?\(\s*(?:\d+\,\s*){3}\d*\.?\d+%?\s*\)/,
          /rgba?\(\s*(?:\d+\s*){2}\d+\s*\/\s*\d?\.?\d+%?\s*\)/,
          /rgba?\(\s*(?:\d+%\s*){2}\d+%\s*\/\s*\d?\.?\d+%?\s*\)/,
          /hsla?\(\s*\d+(?:deg|rad|grad|turn)?\,\s*\d+%\,\s*\d+%\s*\)/,
          /hsla?\(\s*\d+(?:deg|rad|grad|turn)?\s+\d+%\s+\d+%\s*\)/,
          /hsla?\(\s*\d+(?:deg|rad|grad|turn)?\,\s*(?:\d+%\,\s*){2}\d?\.?\d+%?\s*\)/,
          /hsla?\(\s*\d+(?:deg|rad|grad|turn)?\s+\d+%\s+\d+%\s*\/\s*\d?\.?\d+%?\s*\)/,
        )

        COLOR_CODE_PATTERN = /\A\s*(#{REGEXPS})\s*\z/

        def call
          doc.search(".//code").each do |node|
            if (color = node.inner_text) =~ COLOR_CODE_PATTERN
              node.add_child(color_element(color.strip))
            end
          end
          doc
        end

        private

        def color_element(color)
          %(<span class=#{inline_code_color_class_name} style="background-color: #{color};"></span>)
        end

        def inline_code_color_class_name
          context[:inline_code_color_class_name] || DEFAULT_CLASS_NAME
        end
      end
    end
  end
end
