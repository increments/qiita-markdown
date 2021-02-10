module Qiita
  module Markdown
    module Embed
      module SpeekerDeck
        SCRIPT_URLS = [
          "//speakerdeck.com/assets/embed.js",
        ].freeze
        CLASS_NAME = %w[speakerdeck-embed].freeze
        DATA_ATTRIBUTES = %w[
          data-id data-ratio
        ].freeze
        ATTRIBUTES = %w[class] + DATA_ATTRIBUTES
      end
    end
  end
end
