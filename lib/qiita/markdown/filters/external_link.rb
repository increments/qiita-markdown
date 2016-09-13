require "addressable/uri"

module Qiita
  module Markdown
    module Filters
      class ExternalLink < HTML::Pipeline::Filter
        def call
          doc.search("a").each do |anchor|
            next unless anchor["href"]
            href = anchor["href"].strip
            href_host = host_of(href)
            next unless href_host
            if href_host != hostname
              anchor["rel"] = "nofollow noopener"
              anchor["target"] = "_blank"
            end
          end

          doc
        end

        def validate
          needs :hostname
        end

        private

        def host_of(url)
          uri = Addressable::URI.parse(url)
          uri.host
        rescue Addressable::URI::InvalidURIError
          nil
        end

        def hostname
          context[:hostname]
        end
      end
    end
  end
end
