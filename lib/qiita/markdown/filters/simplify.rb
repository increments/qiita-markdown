module Qiita
  module Markdown
    module Filters
      # A filter for simplifying document structure by removing complex markups
      # (mainly block elements) and complex contents.
      #
      # The logic of this filter is similar to the `FinalSanitizer` filter, but this
      # does not use the `sanitize` gem internally for the following reasons:
      #
      # * Each filter should do only its own responsibility, and this filter is
      #   _not_ for sanitization.
      #
      # * The `sanitize` gem automatically adds extra transformers even if we
      #   want to clean up only some elements, and they would be run in the
      #   `FinalSanitizer` filter later.
      #   https://github.com/rgrove/sanitize/blob/v3.1.2/lib/sanitize.rb#L77-L100
      class Simplify < HTML::Pipeline::Filter
        SIMPLE_ELEMENTS = %w[a b code em i ins q s samp span strike strong sub sup var]

        COMPLEX_CONTENT_ELEMENTS = %w[table]

        def call
          remove_complex_contents
          clean_complex_markups
          doc
        end

        private

        # Remove complex elements along with their contents entirely.
        def remove_complex_contents
          selector = COMPLEX_CONTENT_ELEMENTS.join(",")
          doc.search(selector).each(&:remove)
        end

        # Remove complex markups while keeping their contents.
        def clean_complex_markups
          doc.traverse do |node|
            next unless node.element?
            next if SIMPLE_ELEMENTS.include?(node.name)
            node.replace(node.children)
          end
        end
      end
    end
  end
end
