module Qiita
  module Markdown
    module Filters
      # 1. Detects language written in <pre> element.
      # 2. Adds lang attribute (but this attribute is consumed by syntax highliter).
      # 3. Adds detected code data into `result[:codes]`.
      class Code < HTML::Pipeline::Filter
        def call
          result[:codes] ||= []
          doc.search("pre").each do |pre|
            if code = pre.at("code")
              label = Label.new(code["class"])
              pre["lang"] = label.language if label.language
              result[:codes] << {
                code: pre.text,
                filename: label.filename,
                language: label.language,
              }
            end
          end
          doc
        end

        # Detects language from code block label.
        class Label
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
          #   Label.new(nil).language #=> nil
          #   Label.new("ruby").language #=> "ruby"
          #   Label.new("ruby:foo.rb").language #=> "ruby"
          #   Label.new("foo.rb").language #=> "ruby"
          # @return [String, nil]
          def language
            case
            when empty?
              nil
            when !has_only_filename?
              section[0]
            when linguist_language
              linguist_language.default_alias_name
            end
          end

          private

          def empty?
            @text.nil?
          end

          def has_only_filename?
            sections[1].nil? && sections[0].include?(".")
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
