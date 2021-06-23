module Qiita
  module Markdown
    module Filters
      class Greenmat < HTML::Pipeline::TextFilter
        DEFAULT_OPTIONS = {
          footnotes: true,
        }.freeze

        # @return [Nokogiri::HTML::DocumentFragment]
        def call
          Nokogiri::HTML.fragment(greenmat.render(@text))
        end

        private

        # Memoize.
        # @return [Greenmat::Markdown]
        def greenmat
          @renderer ||= ::Greenmat::Markdown.new(
            Qiita::Markdown::Greenmat::HTMLRenderer.new(hard_wrap: true, with_toc_data: true),
            autolink: true,
            fenced_code_blocks: true,
            fenced_custom_blocks: true,
            footnotes: options[:footnotes],
            no_intra_emphasis: true,
            no_mention_emphasis: true,
            strikethrough: true,
            tables: true,
          )
        end

        def options
          @options ||= DEFAULT_OPTIONS.merge(context[:markdown] || {})
        end
      end
    end
  end
end
