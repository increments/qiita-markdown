module Qiita
  module Markdown
    module Filters
      # A filter for truncating a document without breaking the document
      # structure.
      #
      # You can pass `:length` and `:omission` option to :truncate context.
      #
      # @example
      #   Truncate.new(doc, truncate: { length: 50, omission: '... (continued)' })
      class Truncate < HTML::Pipeline::Filter
        DEFAULT_OPTIONS = {
          length: 100,
          omission: "…".freeze,
        }.freeze

        def call
          @current_length = 0
          @previous_char_was_blank = false

          traverse(doc) do |node|
            if exceeded?
              node.remove
            elsif node.text?
              process_text_node(node)
            end
          end

          doc
        end

        private

        # Traverse the given node recursively in the depth-first order.
        # Note that we cannot use Nokogiri::XML::Node#traverse
        # since it traverses the node's descendants _before_ the node itself.
        # https://github.com/sparklemotion/nokogiri/blob/v1.6.6.2/lib/nokogiri/xml/node.rb#L571-L574
        def traverse(node, &block)
          yield(node)

          node.children.each do |child_node|
            traverse(child_node, &block)
          end
        end

        def exceeded?
          @current_length > max_length
        end

        def process_text_node(node)
          node.content.each_char.with_index do |char, index|
            current_char_is_blank = char.strip.empty?

            if !@previous_char_was_blank || !current_char_is_blank
              @current_length += 1
            end

            @previous_char_was_blank = current_char_is_blank

            if exceeded?
              node.content = node.content.slice(0...(index - omission.size)) + omission
              break
            end
          end
        end

        def max_length
          options[:length]
        end

        def omission
          options[:omission] || "".freeze
        end

        def options
          @options ||= DEFAULT_OPTIONS.merge(context[:truncate] || {})
        end
      end
    end
  end
end
