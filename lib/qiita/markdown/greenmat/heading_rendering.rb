module Qiita
  module Markdown
    module Greenmat
      module HeadingRendering
        def heading_counter
          @counter ||= Hash.new(0)
        end

        class AbstractHeading
          attr_reader :raw_body, :level, :counter, :escape_html
          alias escape_html? escape_html

          def initialize(raw_body, level, counter, escape_html = false)
            @raw_body = raw_body
            @level = level
            @counter = counter
            @escape_html = escape_html
          end

          def to_s
            fail NotImplementedError
          end

          def increment
            fail NotImplementedError
          end

          private

          def count
            counter[id]
          end

          def has_count?
            count > 0
          end

          def body
            escape_html? ? CGI.escape_html(raw_body) : raw_body
          end

          def id
            @id ||= text.downcase.gsub(/[^\p{Word}\- ]/u, "").tr(" ", "-")
          end

          def text
            Nokogiri::HTML.fragment(raw_body).text
          end

          def suffix
            has_count? ? "-#{count}" : ""
          end

          def suffixed_id
            @suffixed_id ||= "#{id}#{suffix}"
          end
        end
      end
    end
  end
end
