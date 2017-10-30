module Qiita
  module Markdown
    module Filters
      DEFAULT_LANGUAGE_ALIASES = {
        "el" => "common-lisp",
        "hack" => "php",
        "zsh" => "bash",
      }

      # 1. Detects language written in <pre> element.
      # 2. Adds lang attribute (but this attribute is consumed by syntax highlighter).
      # 3. Adds detected code data into `result[:codes]`.
      #
      # You can pass language aliases table via context[:language_aliases].
      class CodeBlock < HTML::Pipeline::Filter
        def call
          result[:codes] ||= []
          doc.search("pre").each do |pre|
            if (code = pre.at("code"))
              metadata = Metadata.new(code["data-metadata"])
              filename = metadata.filename
              language = metadata.language
              language = language_aliases[language] || language
              pre["filename"] = filename if filename
              pre["lang"] = language if language
              result[:codes] << {
                code: pre.text,
                filename: filename,
                language: language,
              }
            end
          end
          doc
        end

        private

        def language_aliases
          context[:language_aliases] || DEFAULT_LANGUAGE_ALIASES
        end

        # Detects language from code block metadata.
        class Metadata
          # @param text [String, nil]
          def initialize(text)
            @text = text
          end

          # @return [String, nil]
          def filename
            case
            when empty?
              nil
            when has_only_filename?
              sections[0]
            else
              sections[1]
            end
          end

          # @example
          #   Metadata.new(nil).language #=> nil
          #   Metadata.new("ruby").language #=> "ruby"
          #   Metadata.new("ruby:foo.rb").language #=> "ruby"
          #   Metadata.new("foo.rb").language #=> "ruby"
          # @return [String, nil]
          def language
            case
            when empty?
              nil
            when !has_only_filename?
              sections[0]
            when linguist_language
              linguist_language.default_alias_name
            end
          end

          private

          def empty?
            @text.nil?
          end

          def has_only_filename?
            sections[1].nil? && sections[0] && sections[0].include?(".")
          end

          def linguist_language
            @linguist_language ||= Linguist::Language.find_by_filename(filename).first
          end

          def sections
            @sections ||= (@text || "").split(":")
          end
        end
      end
    end
  end
end
