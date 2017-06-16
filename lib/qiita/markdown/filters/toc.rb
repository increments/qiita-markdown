module Qiita
  module Markdown
    module Filters
      class Toc < HTML::Pipeline::Filter
        def call
          doc.css("h1[id], h2[id], h3[id], h4[id], h5[id], h6[id]").each do |node|
            Heading.new(node).decorate
          end
          doc
        end

        class Heading
          def initialize(node)
            @node = node
            @id = node.attr("id")
            raise unless @id
          end

          def decorate
            remove_heading_id
            first_child.add_previous_sibling(anchor_element) if first_child
          end

          def remove_heading_id
            @node.remove_attribute("id")
          end

          def anchor_element
            %(<span id="#{@id}" class="fragment"></span><a href="##{@id}"><i class="fa fa-link"></i></a>)
          end

          def first_child
            @first_child ||= @node.children.first
          end
        end
      end
    end
  end
end
