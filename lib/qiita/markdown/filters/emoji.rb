module Qiita
  module Markdown
    module Filters
      class Emoji < HTML::Pipeline::EmojiFilter
        # @note Override
        # Overriding with no-op to disable :asset_host context check
        # since emoji URLs can also be generated with :emoji_url_generator context.
        def validate
        end

        private

        # @note Override
        def emoji_url(name)
          url = emoji_url_generator.call(name) if emoji_url_generator
          url || super
        end

        def emoji_url_generator
          context[:emoji_url_generator]
        end

        # @note Override
        def emoji_pattern
          @emoji_pattern ||= /:(#{Regexp.union(emoji_names).source}):/
        end

        def emoji_names
          context[:emoji_names] || self.class.emoji_names
        end
      end
    end
  end
end
