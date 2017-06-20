require "addressable/uri"

module Qiita
  module Markdown
    module Filters
      class CodePen < HTML::Pipeline::Filter
        HOST = "codepen.io".freeze
        PATH_PATTERN = %r{\A/(?<username>\w+)/pen/(?<id>\w+)/?\z}

        def call
          doc.search("a").each do |anchor|
            next unless anchor["href"]

            href = anchor["href"].strip
            next unless pen?(href)

            iframe, = anchor.replace("<iframe>#{anchor.to_html}</iframe>")
            add_iframe_attributes(iframe, href)
          end

          doc
        end

        private

        def add_iframe_attributes(iframe, href)
          m = PATH_PATTERN.match(path_of(href))
          iframe["height"] = height = 500
          iframe["scrolling"] = "no"
          iframe["title"] = m[:id]
          iframe["src"] = "//codepen.io/#{m[:username]}/embed/#{m[:id]}/?height=#{height}&theme-id=light&default-tab=html,result&embed-version=2"
          iframe["frameborder"] = "no"
          iframe["allowtransparency"] = "true"
          iframe["allowfullscreen"] = "true"
          iframe["style"] = "width: 100%;"
        end

        def host_of(url)
          uri = Addressable::URI.parse(url)
          uri.host
        rescue Addressable::URI::InvalidURIError
          nil
        end

        def path_of(url)
          uri = Addressable::URI.parse(url)
          uri.path
        rescue Addressable::URI::InvalidURIError
          nil
        end

        def pen?(href)
          href_host = host_of(href)
          return unless href_host == HOST

          path = path_of(href)
          return unless path

          PATH_PATTERN =~ path
        end
      end
    end
  end
end
