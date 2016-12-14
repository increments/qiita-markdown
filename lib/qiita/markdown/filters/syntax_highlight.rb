module Qiita
  module Markdown
    module Filters
      class SyntaxHighlight < HTML::Pipeline::Filter
        def call
          doc.search("pre").each do |node|
            Highlighter.new(node).call
          end
          doc
        end

        class Highlighter
          # @param node [Nokogiri::XML::Node]
          def initialize(node)
            @node = node
          end

          # @note The following is a formatted example output from this method.
          #   <div class="code-frame" data-lang="ruby">
          #     <div class="code-lang">
          #       <span class="bold">example.rb</span>
          #      </div>
          #     <div class="highlight">
          #       <pre>
          #         <span class="mi">1</span>
          #       </pre>
          #     </div>
          #   </div>
          def call
            outer = ::Nokogiri::HTML.fragment(%Q[<div class="code-frame" data-lang="#{language || 'text'}"></div>])
            frame = outer.at("div")
            frame.add_child(filename_node) if filename
            frame.add_child(highlighted_node)
            @node.replace(outer)
          end

          private

          # @return [String] The raw code (e.g. `"1 + 1\n"`)
          def code
            @node.inner_text
          end

          # @return [String, nil] The filename detected at Qiita::Markdown::Filters::Code (e.g. `"config.ru"`)
          def filename
            @node["filename"]
          end

          # @return [String]
          def filename_node
            %Q[<div class="code-lang"><span class="bold">#{filename}</span></div>]
          end

          # @return [String]
          def highlighted_code
            if language
              lexer_class = ::Rouge::Lexer.find(language)
              if lexer_class
                tokens = lexer_class.new(lexer_options).lex(code)
                ::Rouge::Formatters::HTML.new.format(tokens)
              else
                code
              end
            else
              code
            end
          end

          # @return [Nokogiri::HTML::DocumentFragment]
          def highlighted_node
            fragment = ::Nokogiri::HTML.fragment(%[<div class="highlight"><pre></pre></div>])
            fragment.at("pre").add_child(highlighted_code)
            fragment
          end

          # @return [String] The language name detected at Qiita::Markdown::Filters::Code (e.g. `"ruby"`)
          def language
            @node["lang"]
          end

          # @return [Hash]
          def lexer_options
            if language == "php" && !code.include?("<?php")
              { start_inline: true }
            else
              {}
            end
          end
        end
      end
    end
  end
end
