module Qiita
  module Markdown
    module Greenmat
      module HeadingRendering
        def heading_counter
          @counter ||= Hash.new(0)
        end

        AbstractHeading = Struct.new(:text, :level, :counter) do
          def to_s
            fail NotImplementedError
          end

          def increment
            fail NotImplementedError
          end

          private

          def count
            counter[id]
          end

          def has_count?
            count > 0
          end

          def id
            @id ||= text.downcase.gsub(/[^\p{Word}\- ]/u, "").gsub(" ", "-")
          end

          def suffix
            has_count? ? "-#{count}" : ""
          end

          def suffixed_id
            @suffixed_id ||= "#{id}#{suffix}"
          end
        end
      end
    end
  end
end
