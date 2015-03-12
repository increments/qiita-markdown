module Qiita
  module Markdown
    # A processor for rendering a summary of markdown document. This simplifies
    # a document by removing complex markups and also truncates it to a
    # specific length without breaking the document structure.
    class SummaryProcessor < Processor
      DEFAULT_FILTERS = [
        Filters::Redcarpet,
        Filters::Simplify,
        HTML::Pipeline::EmojiFilter,
        Filters::Mention,
        Filters::Sanitize,
        Filters::Truncate
      ]

      # @note Modify filters if you want.
      # @return [Array<HTML::Pipeline::Filter>]
      def filters
        @filters ||= DEFAULT_FILTERS
      end
    end
  end
end
