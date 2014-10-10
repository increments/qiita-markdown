module Qiita
  module Markdown
    module Filters
      # Converts [ ] or [x] into checkbox element.
      #
      # * [x] Foo
      # * [ ] Bar
      # * [ ] Baz
      #
      # Takes following context options:
      #
      # * :checkbox_disabled - Pass true to add `disabled` attribute to input element
      #
      class Checkbox < HTML::Pipeline::Filter
        def call
          doc.search("li").each_with_index do |li, index|
            list = List.new(disabled: context[:checkbox_disabled], index: index, node: li)
            list.convert if list.has_checkbox?
          end
          doc
        end

        class List
          CHECKBOX_CLOSE_MARK = "[x] "
          CHECKBOX_OPEN_MARK  = "[ ] "

          def initialize(disabled: nil, index: nil, node: nil)
            @disabled = disabled
            @index = index
            @node = node
          end

          def has_checkbox?
            has_open_checkbox? || has_close_checkbox?
          end

          def convert
            @node.content = @node.content.sub(checkbox_mark, "")
            @node.prepend_child(checkbox_node)
          end

          private

          def checkbox_mark
            case
            when has_close_checkbox?
              CHECKBOX_CLOSE_MARK
            when has_open_checkbox?
              CHECKBOX_OPEN_MARK
            end
          end

          def checkbox_node
            node = Nokogiri::HTML.fragment('<input type="checkbox">')
            node.children.first["data-checkbox-index"] = @index
            node.children.first["checked"] = true if has_close_checkbox?
            node.children.first["disabled"] = true if @disabled
            node
          end

          def has_close_checkbox?
            if instance_variable_defined?(:@has_close_checkbox)
              @has_close_checkbox
            else
              @has_close_checkbox = @node.content.start_with?(CHECKBOX_CLOSE_MARK)
            end
          end

          def has_open_checkbox?
            if instance_variable_defined?(:@has_open_checkbox)
              @has_open_checkbox
            else
              @has_open_checkbox = @node.content.start_with?(CHECKBOX_OPEN_MARK)
            end
          end
        end
      end
    end
  end
end
