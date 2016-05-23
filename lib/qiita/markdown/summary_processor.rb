module Qiita
  module Markdown
    # A processor for rendering a summary of markdown document. This simplifies
    # a document by removing complex markups and also truncates it to a
    # specific length without breaking the document structure.
    class SummaryProcessor < Processor
      DEFAULT_CONTEXT = {
        asset_root: "/images",
        markdown: {
          footnotes: false
        },
      }

      DEFAULT_FILTERS = [
        Filters::Greenmat,
        Filters::Simplify,
        Filters::Emoji,
        Filters::Mention,
        Filters::ExternalLink,
        Filters::Sanitize,
        Filters::Truncate,
      ]

      # @param [Hash] context Optional context for HTML::Pipeline.
      def initialize(context = {})
        @context = DEFAULT_CONTEXT.merge(context)
      end

      # Converts Markdown text into HTML string with extracted metadata.
      #
      # @param [String] input Markdown text.
      # @param [Hash] context Optional context merged into default context.
      # @return [Hash] Process result.
      # @example
      #   Qiita::Markdown::SummaryProcessor.new.call(markdown) #=> {
      #     codes: [...],
      #     mentioned_usernames: [...],
      #     output: "...",
      #   }
      def call(input, context = {})
        HTML::Pipeline.new(filters, @context).call(input, context)
      end

      # @note Modify filters if you want.
      # @return [Array<HTML::Pipeline::Filter>]
      def filters
        @filters ||= DEFAULT_FILTERS.clone
      end
    end
  end
end
