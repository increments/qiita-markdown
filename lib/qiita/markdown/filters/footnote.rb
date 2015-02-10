module Qiita
  module Markdown
    module Filters
      class Footnote < HTML::Pipeline::Filter
        def call
          doc.search("sup > a").each do |a|
            footnote = find_footnote(a)
            next unless footnote
            a[:title] = footnote.text.gsub(/\A\n/, "").gsub(/ ↩\n\z/, "")
          end
          doc
        end

        private

        def find_footnote(a)
          href = a["href"]
          return nil if !href || href.match(/\A#fn\d+\z/).nil?
          doc.search(href).first
        end
      end
    end
  end
end
