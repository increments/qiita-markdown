module Qiita
  module Markdown
    module Filters
      class OpenContent < HTML::Pipeline::Filter
        def call
          doc.search("a.autolink").each do |node|
            next if node["href"].blank?
            next unless simple_anchor_tag?(node)

            href = node["href"].strip
            href_host = host_of(href)
            next if href_host.blank?

            if href.include?("https://www.youtube.com/watch?v=")
              embed_href = href.gsub("www.youtube.com/watch?v=", "www.youtube.com/embed/")
              node.replace("<iframe width=\"560\" height=\"420\" src=\"#{embed_href}\" frameborder=\"0\" allow=\"accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture\" allowfullscreen></iframe>")
            end
          end
          doc
        end

        private

        def simple_anchor_tag?(node)
          return false if node.children.any? { |child| child.name != "text" }
          return false if node.ancestors.any? do |ancestor|
            next false if ancestor.name == "#document-fragment"
            ancestor.name != "p" || ancestor.children.size > 1
          end

          true
        end

        def host_of(url)
          uri = ::Addressable::URI.parse(url)
          uri.host
        rescue ::Addressable::URI::InvalidURIError
          nil
        end
      end
    end
  end
end
