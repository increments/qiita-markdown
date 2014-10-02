module Qiita
  module Markdown
    module Filters
      class Toc < HTML::Pipeline::Filter
        def call
          counter = Hash.new(0)
          doc.css("h1, h2, h3, h4, h5, h6").each do |node|
            heading = Heading.new(node, counter)
            heading.add_anchor_element if heading.has_first_child?
            heading.increment
          end
          doc
        end

        class Heading
          def initialize(node, counter)
            @node = node
            @counter = counter
          end

          def add_anchor_element
            first_child.add_previous_sibling(anchor_element)
          end

          def anchor_element
            %[<span id="#{suffixed_id}" class="fragment"></span><a href="##{suffixed_id}"><i class="fa fa-link"></i></a>]
          end

          def content
            @content ||= node.children.first
          end

          def count
            @counter[id]
          end

          def first_child
            @first_child ||= @node.children.first
          end

          def has_count?
            count > 0
          end

          def has_first_child?
            !!first_child
          end

          def id
            @node.text.downcase.gsub(/[^\p{Word}\- ]/u, '').gsub(' ', '-')
          end

          def increment
            @counter[id] += 1
          end

          def suffix
            has_count? ? "-#{count}" : ""
          end

          def suffixed_id
            "#{id}#{suffix}"
          end
        end
      end
    end
  end
end
