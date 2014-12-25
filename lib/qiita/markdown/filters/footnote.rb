module Qiita
  module Markdown
    module Filters
      class Footnote < HTML::Pipeline::Filter
        def call
          doc.search("sup > a").each do |a|
            href = a["href"]
            if href.start_with?("#") && (li = doc.search(href).first)
              a[:title] = li.text.gsub(/\A\n/, "").gsub(/ ↩\n\z/, "")
            end
          end
          doc
        end
      end
    end
  end
end
