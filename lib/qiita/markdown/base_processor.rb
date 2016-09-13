module Qiita
  module Markdown
    # An abstract base processor for rendering a Markdown document.
    class BaseProcessor
      # @return [Hash] the default context for HTML::Pipeline
      def self.default_context
        raise NotImplementedError
      end

      # @return [Array<Class>] the default HTML::Pipeline filter classes
      def self.default_fiters
        raise NotImplementedError
      end

      # @param [Hash] context Optional context for HTML::Pipeline.
      def initialize(context = {})
        @context = self.class.default_context.merge(context)
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
        @filters ||= self.class.default_filters
      end
    end
  end
end
