module Qiita
  module Markdown
    class Processor
      DEFAULT_CONTEXT = {
        asset_root: "/images",
      }

      DEFAULT_FILTERS = [
        Filters::Greenmat,
        Filters::ImageLink,
        Filters::Footnote,
        Filters::Code,
        Filters::Checkbox,
        Filters::Emoji,
        Filters::SyntaxHighlight,
        Filters::Mention,
        Filters::Sanitize,
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
      #   Qiita::Markdown::Processor.new.call(markdown) #=> {
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
