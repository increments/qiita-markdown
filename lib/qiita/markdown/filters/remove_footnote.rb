module Qiita
  module Markdown
    module Filters
      class RemoveFootnote < HTML::Pipeline::Filter
        def call
          doc.search("a").each do |a|
            a.parent.remove if footnote?(a)
            a.remove if footnote_ref?(a)
          end
          doc
        end

        private

        def footnote?(a)
          href = a["href"]
          a && href.match(/\A#fn\d+\z/).present?
        end

        def footnote_ref?(a)
          href = a["href"]
          a && href.match(/\A#fnref\d+\z/).present?
        end
      end
    end
  end
end
