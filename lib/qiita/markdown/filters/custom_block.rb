# frozen_string_literal: true

module Qiita
  module Markdown
    module Filters
      class CustomBlock < HTML::Pipeline::Filter
        ALLOWED_TYPES = %w[note].freeze

        def call
          doc.search('div[data-type="customblock"]').each do |div|
            metadata = Metadata.new(div["data-metadata"])
            next unless ALLOWED_TYPES.include?(metadata.type)

            klass = Object.const_get("#{self.class}::#{metadata.type.capitalize}")
            klass.new(div, metadata.subtype).convert
          end
          doc
        end

        class Metadata
          attr_reader :type, :subtype

          # @param text [String, nil]
          # @note Attribute `type` will be nil if `text` is nil
          # @note Attribute `subtype` will be nil if `text` does not include white space.
          def initialize(text)
            # Discared after the second word.
            @type, @subtype = text && text.split(" ")
          end
        end

        class Note
          attr_reader :node, :type

          ALLOWED_TYPES = %w[info warn alert].freeze
          DEFAULT_TYPE = "info"

          # @param node [Nokogiri::XML::Node]
          # @param type [String, nil]
          def initialize(node, type)
            @node = node
            @type = ALLOWED_TYPES.include?(type) ? type : DEFAULT_TYPE
          end

          def convert
            children = node.children
            children.each(&:unlink)
            node.add_child("<div></div>")
            node.children.first.children = children
            node["class"] = "note #{type}"
            node.children.first.add_previous_sibling(icon) if icon
          end

          private

          def icon
            {
              info: %(<span class="fa fa-fw fa-check-circle"></span>),
              warn: %(<span class="fa fa-fw fa-exclamation-circle"></span>),
              alert: %(<span class="fa fa-fw fa-times-circle"></span>),
            }[type.to_sym]
          end
        end
      end
    end
  end
end
