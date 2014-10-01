module Qiita
  module Markdown
    class Processor
      # Converts Markdown text into HTML string and some metadata.
      #
      # @param [String] Markdown text.
      # @return [Hash] Process result.
      def call(input)
        pipeline.call(input)
      end

      private

      # @return [HTML::Pipeline]
      def pipeline
        HTML::Pipeline.new(
          [
            Filters::Redcarpet,
            Filters::Mention,
          ],
        )
      end
    end
  end
end
