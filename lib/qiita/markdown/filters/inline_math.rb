# frozen_string_literal: true

module Qiita
  module Markdown
    module Filters
      class InlineMath < HTML::Pipeline::Filter
        def call
          doc.search(".//code").each do |code|
            opening = code.previous
            closing = code.next
            replace_with_math_span(code, opening, closing) if inline_math_code?(opening, closing)
          end

          doc
        end

        private

        def inline_math_code?(opening, closing)
          opening.present? && closing.present? && valid_opening?(opening) && valid_closing?(closing)
        end

        def valid_opening?(opening)
          opening.text? && opening.content.end_with?("$") && !opening.content.end_with?("$$")
        end

        def valid_closing?(closing)
          closing.text? && closing.content.start_with?("$") && !closing.content.start_with?("$$")
        end

        def replace_with_math_span(code, opening, closing)
          span = Nokogiri::XML::Node.new("span", doc)
          span.add_child(Nokogiri::XML::Text.new("$#{code.text}$", doc))
          code.replace(span)
          opening.content = opening.content.delete_suffix("$")
          opening.remove if opening.content.empty?
          closing.content = closing.content.delete_prefix("$")
          closing.remove if closing.content.empty?
        end
      end
    end
  end
end
