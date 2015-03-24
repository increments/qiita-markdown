require "greenmat"

module Qiita
  module Markdown
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
    end
  end
end
