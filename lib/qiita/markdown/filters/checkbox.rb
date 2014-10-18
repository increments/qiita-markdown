module Qiita
  module Markdown
    module Filters
      # Converts [ ] and [x] into checkbox elements.
      #
      # * [x] Foo
      # * [ ] Bar
      # * [ ] Baz
      #
      class Checkbox < HTML::Pipeline::Filter
        def call
          doc.search("li").each do |li|
            list = List.new(li)
            list.convert if list.has_checkbox?
          end
          doc
        end

        class List
          include Mem

          CHECKBOX_CLOSE_MARK = "[x] "
          CHECKBOX_OPEN_MARK  = "[ ] "

          def initialize(node)
            @node = node
          end

          def has_checkbox?
            has_open_checkbox? || has_close_checkbox?
          end

          def convert
            first_text_node.content = first_text_node.content.sub(checkbox_mark, "")
            first_text_node.add_previous_sibling(checkbox_node)
            @node["class"] = "task-list-item"
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
            node = Nokogiri::HTML.fragment('<input type="checkbox" class="task-list-item-checkbox">')
            node.children.first["checked"] = true if has_close_checkbox?
            node.children.first["disabled"] = true
            node
          end

          def first_text_node
            if @node.children.first && @node.children.first.name == "p"
              @node.children.first.children.first
            else
              @node.children.first
            end
          end
          memoize :first_text_node

          def has_close_checkbox?
            !!first_text_node && first_text_node.text? && first_text_node.content.start_with?(CHECKBOX_CLOSE_MARK)
          end
          memoize :has_close_checkbox?

          def has_open_checkbox?
            !!first_text_node && first_text_node.text? && first_text_node.content.start_with?(CHECKBOX_OPEN_MARK)
          end
          memoize :has_open_checkbox?
        end
      end
    end
  end
end
