module Qiita
  module Markdown
    class Processor
      DEFAULT_FILTERS = [
        Filters::Redcarpet,
        Filters::Code,
        HTML::Pipeline::SyntaxHighlightFilter,
        Filters::Mention,
      ]

      # @param context [Hash] Optional context for HTML::Pipeline.
      def initialize(context = {})
        @context = context
      end

      # Converts Markdown text into HTML string with extracted metadata.
      #
      # @param [String] Markdown text.
      # @return [Hash] Process result.
      # @example
      #   Qiita::Markdown::Processor.new.call(markdown) #=> {
      #     codes: [...],
      #     mentioned_usernames: [...],
      #     output: "...",
      #   }
      def call(input)
        HTML::Pipeline.new(filters, @context).call(input)
      end

      # @note Modify filters if you want.
      # @return [Array<HTML::Pipeline::Filter>]
      def filters
        @filters ||= DEFAULT_FILTERS
      end
    end
  end
end
