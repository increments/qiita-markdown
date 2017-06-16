module Qiita
  module Markdown
    # A processor for rendering a summary of markdown document. This simplifies
    # a document by removing complex markups and also truncates it to a
    # specific length without breaking the document structure.
    class SummaryProcessor < BaseProcessor
      def self.default_context
        {
          asset_root: "/images",
          markdown: {
            footnotes: false,
          },
        }
      end

      def self.default_filters
        [
          Filters::Greenmat,
          Filters::UserInputSanitizer,
          Filters::Simplify,
          Filters::Emoji,
          Filters::Mention,
          Filters::ExternalLink,
          Filters::FinalSanitizer,
          Filters::Truncate,
        ]
      end
    end
  end
end
