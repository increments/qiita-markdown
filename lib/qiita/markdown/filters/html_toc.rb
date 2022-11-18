# frozen_string_literal: true

module Qiita
  module Markdown
    module Filters
      class HtmlToc < ::HTML::Pipeline::Filter
        # @return [Nokogiri::HTML::DocumentFragment]
        def call
          headings = doc.search("h1, h2, h3, h4, h5, h6")
          return "" if headings.empty?

          toc = %W[<ul>\n]
          top_level = nil
          last_level = nil
          depth = 1

          headings.each do |node|
            heading_rank = node.name.match(/h(\d)/)[1].to_i

            # The first heading is displayed as the top level.
            # The following headings, of higher rank than the first, are placed as top level.
            top_level ||= heading_rank
            current_level = [heading_rank, top_level].max

            link = toc_with_link(node.text, node.attributes["id"]&.value)
            toc << (nest_string(last_level, current_level) + link)

            depth += current_level - last_level if last_level

            last_level = current_level
          end

          toc << ("</li>\n</ul>\n" * depth)
          toc.join
        end

        private

        # @param text [String]
        # @param id [String]
        # @return [String]
        def toc_with_link(text, id)
          %(<a href="##{id}">#{CGI.escapeHTML(text)}</a>\n)
        end

        # @param last_level [Integer, nil]
        # @param current_level [Integer]
        # @return [String]
        def nest_string(last_level, current_level)
          if last_level.nil?
            return "<li>\n"
          elsif current_level == last_level
            return "</li>\n<li>\n"
          elsif current_level > last_level
            level_difference = current_level - last_level
            return "<ul>\n<li>\n" * level_difference
          elsif current_level < last_level
            level_difference = last_level - current_level
            return %(#{"</li>\n</ul>\n" * level_difference}</li>\n<li>\n)
          end

          ""
        end
      end
    end
  end
end
