module Qiita
  module Markdown
    module Filters
      class ImageLink < ::HTMLPipelineFilter
        def call
          doc.search("img").each do |img|
            next if img.ancestors.any? { |ancestor| ancestor.name == "a" }

            outer = Nokogiri::HTML.fragment(%(<a href="#{img['src']}" target="_blank"></a>))
            inner = img.clone
            outer.at("a").add_child(inner)
            img.replace(outer)
          end
          doc
        end
      end
    end
  end
end
