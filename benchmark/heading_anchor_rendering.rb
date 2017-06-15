require "benchmark/ips"
require "qiita/markdown"

# The old implementation
module PostProcess
  class Processor < Qiita::Markdown::Processor
    def filters
      @filters ||= [
        Filters::Greenmat,
        Filters::Toc,
      ]
    end
  end

  module Filters
    class Greenmat < HTML::Pipeline::TextFilter
      class << self
        # Memoize.
        # @return [Greenmat::Markdown]
        def renderer
          @renderer ||= ::Greenmat::Markdown.new(
            ::Greenmat::Render::HTML.new(
              hard_wrap: true,
            ),
            autolink: true,
            fenced_code_blocks: true,
            footnotes: true,
            no_intra_emphasis: true,
            no_mention_emphasis: true,
            strikethrough: true,
            tables: true,
          )
        end
      end

      # @return [Nokogiri::HTML::DocumentFragment]
      def call
        Nokogiri::HTML.fragment(self.class.renderer.render(@text))
      end
    end

    class Toc < HTML::Pipeline::Filter
      def call
        counter = Hash.new(0)
        doc.css("h1, h2, h3, h4, h5, h6").each do |node|
          heading = Heading.new(node, counter)
          heading.add_anchor_element if heading.has_first_child?
          heading.increment
        end
        doc
      end

      class Heading
        def initialize(node, counter)
          @node = node
          @counter = counter
        end

        def add_anchor_element
          first_child.add_previous_sibling(anchor_element)
        end

        def anchor_element
          %[<span id="#{suffixed_id}" class="fragment"></span><a href="##{suffixed_id}"><i class="fa fa-link"></i></a>]
        end

        def content
          @content ||= node.children.first
        end

        def count
          @counter[id]
        end

        def first_child
          @first_child ||= @node.children.first
        end

        def has_count?
          count > 0
        end

        def has_first_child?
          !!first_child
        end

        def id
          @node.text.downcase.gsub(/[^\p{Word}\- ]/u, "").tr(" ", "-")
        end

        def increment
          @counter[id] += 1
        end

        def suffix
          has_count? ? "-#{count}" : ""
        end

        def suffixed_id
          "#{id}#{suffix}"
        end
      end
    end
  end
end

# The new implementation
module Rendering
  class Processor < Qiita::Markdown::Processor
    def filters
      @filters ||= [
        Filters::Greenmat,
      ]
    end
  end

  module Filters
    class Greenmat < HTML::Pipeline::TextFilter
      def call
        Nokogiri::HTML.fragment(greenmat.render(@text))
      end

      private

      # Memoize.
      # @return [Greenmat::Markdown]
      def greenmat
        @renderer ||= ::Greenmat::Markdown.new(
          HTMLRenderer.new(hard_wrap: true, with_toc_data: true),
          autolink: true,
          fenced_code_blocks: true,
          footnotes: true,
          no_intra_emphasis: true,
          no_mention_emphasis: true,
          strikethrough: true,
          tables: true,
        )
      end

      class HTMLRenderer < ::Greenmat::Render::HTML
        def initialize(extensions = {})
          super
          @with_toc_data = extensions[:with_toc_data]
        end

        def header(text, level)
          heading = heading_class.new(text, level, counter)
          heading.to_s.tap do
            heading.increment
          end
        end

        private

        def heading_class
          @heading_class ||= (@with_toc_data ? HeadingWithAnchor : Heading)
        end

        def counter
          @counter ||= Hash.new(0)
        end

        Heading = Struct.new(:body, :level, :counter) do
          # For reference, C implementation of Redcarpet::Render::HTML#header is the following:
          # https://github.com/vmg/redcarpet/blob/v3.2.3/ext/redcarpet/html.c#L281-L296
          def to_s
            "\n<h#{level}>#{body}</h#{level}>\n"
          end

          def increment
            # no-op
          end

          private

          def content
            body
          end
        end

        class HeadingWithAnchor < Heading
          def to_s
            "\n<h#{level}>#{anchor_element}#{body}</h#{level}>\n"
          end

          def increment
            counter[id] += 1
          end

          private

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
            @id ||= text.downcase.gsub(/[^\p{Word}\- ]/u, "").tr(" ", "-")
          end

          def text
            Nokogiri::HTML.fragment(body).text
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

markdown = File.read(File.join(File.dirname(__FILE__), "sample.md"))

Benchmark.ips do |benchmark|
  benchmark.report("post process") do
    PostProcess::Processor.new.call(markdown)
  end

  benchmark.report("rendering") do
    Rendering::Processor.new.call(markdown)
  end

  benchmark.compare!
end

# Calculating -------------------------------------
#         post process         4 i/100ms
#            rendering        14 i/100ms
# -------------------------------------------------
#         post process       44.9 (±13.4%) i/s -        224 in   5.066301s
#            rendering      151.1 (±16.5%) i/s -        742 in   5.057789s
#
# Comparison:
#            rendering:      151.1 i/s
#         post process:       44.9 i/s - 3.36x slower
