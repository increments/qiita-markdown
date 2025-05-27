module Qiita
  module Markdown
    module Filters
      class GoogleDriveVideo < ::HTML::Pipeline::Filter
        GDRIVE_VIDEO_PATTERN = /@\[gdrive_video\]\((?<url>https?:\/\/[^\)]+)\)/

        def call
          doc.xpath(".//text()").each do |node|
            content = node.to_html
            next if !content.match?(GDRIVE_VIDEO_PATTERN)
            next if has_ancestor?(node, %w(pre code tt))

            html = content.gsub(GDRIVE_VIDEO_PATTERN) do
              video_url = Regexp.last_match[:url]
              embed_url = convert_to_embed_url(video_url)
              if embed_url
                %(<iframe src="#{embed_url}" width="640" height="480" frameborder="0" allowfullscreen="true"></iframe>)
              else
                Regexp.last_match[0]
            end
            node.replace(html)
          end
          doc
        end

        private

        def convert_to_embed_url(share_url)
          if share_url =~ /drive\.google\.com\/file\/d\/([^\/]+)/
            file_id = $1
            "https://drive.google.com/file/d/#{file_id}/preview"
          else
            nil
          end
        end
      end
    end
  end
end