module Qiita
  module Markdown
    module Greenmat
      class HTMLToCRenderer < ::Greenmat::Render::HTML_TOC
        include HeadingRendering

        def initialize(extensions = {})
          super
          @extensions = extensions
          @last_level = 0
        end

        # https://github.com/vmg/redcarpet/blob/v3.2.3/ext/redcarpet/html.c#L609-L642
        def header(text, level)
          @level_offset = level - 1 unless @level_offset

          level -= @level_offset
          level = 1 if level < 1

          difference = level - @last_level
          @last_level = level

          generate_heading_html(text, level, difference)
        end

        # https://github.com/vmg/redcarpet/blob/v3.2.3/ext/redcarpet/html.c#L652-L661
        def doc_footer
          "</li>\n</ul>\n" * @last_level
        end

        private

        def generate_heading_html(text, level, level_difference)
          html = list_item_preceding_html(level_difference)

          anchor = HeadingAnchor.new(text, level, heading_counter, escape_html?)
          html << anchor.to_s
          anchor.increment

          html
        end

        def list_item_preceding_html(level_difference)
          html = case
                 when level_difference > 0
                   "<ul>\n" * level_difference
                 when level_difference < 0
                   "</li>\n" << ("</ul>\n</li>\n" * level_difference.abs)
                 else
                   "</li>\n"
                 end

          html << "<li>\n"
        end

        def escape_html?
          @extensions[:escape_html]
        end

        class HeadingAnchor < AbstractHeading
          def to_s
            "<a href=\"##{suffixed_id}\">#{body}</a>\n"
          end

          def increment
            counter[id] += 1
          end
        end
      end
    end
  end
end
