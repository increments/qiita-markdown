module Qiita
  module Markdown
    module Filters
      class SyntaxHighlight < HTML::Pipeline::Filter
        DEFAULT_LANGUAGE = "text"
        DEFAULT_TIMEOUT = Float::INFINITY

        def call
          elapsed = 0
          timeout_fallback_language = nil
          doc.search("pre").each do |node|
            elapsed += measure_time do
              Highlighter.call(
                default_language: default_language,
                node: node,
                specific_language: timeout_fallback_language,
              )
            end
            if elapsed >= timeout
              timeout_fallback_language = DEFAULT_LANGUAGE
              result[:syntax_highlight_timed_out] = true
            end
          end
          doc
        end

        private

        def default_language
          context[:default_language] || DEFAULT_LANGUAGE
        end

        def measure_time
          t1 = Time.now
          yield
          t2 = Time.now
          t2 - t1
        end

        def timeout
          context[:syntax_highlight_timeout] || DEFAULT_TIMEOUT
        end

        class Highlighter
          def self.call(*args)
            new(*args).call
          end

          def initialize(default_language: nil, node: nil, specific_language: nil)
            @default_language = default_language
            @node = node
            @specific_language = specific_language
          end

          def call
            outer = Nokogiri::HTML.fragment(%Q[<div class="code-frame" data-lang="#{language}">])
            frame = outer.at("div")
            frame.add_child(filename_node) if filename
            frame.add_child(highlighted_node)
            @node.replace(outer)
          end

          private

          def code
            @node.inner_text
          end

          def filename
            @node["filename"]
          end

          def filename_node
            %Q[<div class="code-lang"><span class="bold">#{filename}</span></div>]
          end

          def has_inline_php?
            specific_language == "php" && code !~ /^<\?php/
          end

          def highlight(language)
            Pygments.highlight(code, lexer: language, options: pygments_options)
          end

          def highlighted_node
            if specific_language && Pygments::Lexer.find(specific_language)
              begin
                highlight(specific_language).presence or raise
              rescue
                highlight(@default_language)
              end
            else
              highlight(@default_language)
            end
          end

          def language
            specific_language || @default_language
          end

          def language_node
            Nokogiri::HTML.fragment(%Q[<div class="code-frame" data-lang="#{language}"></div>])
          end

          def pygments_options
            @pygments_options ||= begin
              options = { encoding: "utf-8", stripnl: false }
              options[:startinline] = true if has_inline_php?
              options
            end
          end

          def specific_language
            @specific_language || @node["lang"]
          end
        end
      end
    end
  end
end
