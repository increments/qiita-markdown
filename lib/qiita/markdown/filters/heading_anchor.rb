# frozen_string_literal: true

module Qiita
  module Markdown
    module Filters
      class HeadingAnchor < ::HTMLPipelineFilter
        def call
          doc.search("h1, h2, h3, h4, h5, h6").each do |heading|
            heading["id"] = suffixed_id(heading)
          end

          doc
        end

        private

        def counter
          @counter ||= ::Hash.new(0)
        end

        def get_count(id)
          counter[id]
        end

        def increment_count(id)
          counter[id] += 1
        end

        def heading_id(node)
          node.text.downcase.gsub(/[^\p{Word}\- ]/u, "").tr(" ", "-")
        end

        def suffixed_id(node)
          id = heading_id(node)
          count = get_count(id)
          suffix = count.positive? ? "-#{count}" : ""
          increment_count(id)

          "#{id}#{suffix}"
        end
      end
    end
  end
end
