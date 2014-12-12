require "redcarpet"

module Qiita
  module Markdown
    module Filters
      class Redcarpet < HTML::Pipeline::TextFilter
        class << self
          # Memoize.
          # @return [Redcarpet::Markdown]
          def renderer
            @renderer ||= ::Redcarpet::Markdown.new(
              ::Redcarpet::Render::HTML.new(
                hard_wrap: true,
              ),
              autolink: true,
              fenced_code_blocks: true,
              footnotes: true,
              no_intra_emphasis: true,
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
