module Qiita
  module Markdown
    class Processor < BaseProcessor
      def self.default_context
        {
          asset_root: "/images",
        }
      end

      def self.default_filters
        [
          Filters::QiitaMarker,
          Filters::HeadingAnchor,
          Filters::UserInputSanitizer,
          Filters::ImageLink,
          Filters::Footnote,
          Filters::CodeBlock,
          Filters::CustomBlock,
          Filters::Checkbox,
          Filters::Toc,
          Filters::Emoji,
          Filters::SyntaxHighlight,
          Filters::Mention,
          Filters::GroupMention,
          Filters::ExternalLink,
          Filters::InlineCodeColor,
          Filters::InlineMath,
          Filters::FinalSanitizer,
        ]
      end
    end
  end
end
