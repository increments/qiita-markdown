require "uri"

module Qiita
  module Markdown
    module Greenmat
      class HTMLRenderer < ::Greenmat::Render::HTML
        include HeadingRendering

        def initialize(extensions = {})
          super
          @with_toc_data = extensions[:with_toc_data]
        end

        # https://github.com/vmg/redcarpet/blob/v3.2.3/ext/redcarpet/html.c#L76-L116
        def autolink(link, link_type)
          if link_type == :email
            %(<a href="mailto:#{link}" class="autolink">#{link}</a>)
          else
            %(<a href="#{link}" class="autolink">#{link}</a>)
          end
        end

        def header(text, level)
          heading = heading_class.new(text, level, heading_counter)
          heading.to_s.tap do
            heading.increment
          end
        end

        private

        def heading_class
          @heading_class ||= (@with_toc_data ? HeadingWithAnchor : Heading)
        end

        class Heading < AbstractHeading
          # For reference, C implementation of Redcarpet::Render::HTML#header is the following:
          # https://github.com/vmg/redcarpet/blob/v3.2.3/ext/redcarpet/html.c#L281-L296
          def to_s
            "\n<h#{level}>#{body}</h#{level}>\n"
          end

          def increment
            # No-op
          end
        end

        class HeadingWithAnchor < AbstractHeading
          def to_s
            %(\n<h#{level} id="#{suffixed_id}">#{body}</h#{level}>\n)
          end

          def increment
            counter[id] += 1
          end
        end
      end
    end
  end
end
