module Qiita
  module Markdown
    module Embed
      module Tweet
        SCRIPT_URL = "https://platform.twitter.com/widgets.js"
        CLASS_NAME = %w[twitter-tweet]
        DATA_ATTRIBUTES = %w[
          data-align data-cards data-conversation data-dnt
          data-id data-lang data-link-color data-theme data-width
        ]
        ATTRIBUTES = %w[class] + DATA_ATTRIBUTES
      end
    end
  end
end
