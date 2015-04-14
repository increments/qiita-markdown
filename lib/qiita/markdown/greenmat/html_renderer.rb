module Qiita
  module Markdown
    module Greenmat
      class HTMLRenderer < ::Greenmat::Render::HTML
        def initialize(extensions = {})
          super
          @with_toc_data = extensions[:with_toc_data]
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

        def heading_counter
          @counter ||= Hash.new(0)
        end

        Heading = Struct.new(:text, :level, :counter) do
          # For reference, C implementation of Redcarpet::Render::HTML#header is the following:
          # https://github.com/vmg/redcarpet/blob/v3.2.3/ext/redcarpet/html.c#L281-L296
          def to_s
            "\n<h#{level}>#{content}</h#{level}>\n"
          end

          def increment
            # No-op
          end

          private

          def content
            text
          end
        end

        class HeadingWithAnchor < Heading
          def increment
            counter[id] += 1
          end

          private

          def content
            anchor_element + text
          end

          def anchor_element
            %(<span id="#{suffixed_id}" class="fragment"></span><a href="##{suffixed_id}"><i class="fa fa-link"></i></a>)
          end

          def count
            counter[id]
          end

          def has_count?
            count > 0
          end

          def id
            @id ||= text.downcase.gsub(/[^\p{Word}\- ]/u, "").gsub(" ", "-")
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
