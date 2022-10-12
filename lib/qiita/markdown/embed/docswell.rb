# frozen_string_literal: true

module Qiita
  module Markdown
    module Embed
      module Docswell
        SCRIPT_HOSTS = [
          "docswell.com",
          "www.docswell.com",
        ].freeze
        SCRIPT_URLS = [
          "https://www.docswell.com/assets/libs/docswell-embed/docswell-embed.min.js",
          "//www.docswell.com/assets/libs/docswell-embed/docswell-embed.min.js",
        ].freeze
        CLASS_NAME = %w[docswell-embed].freeze
        DATA_ATTRIBUTES = %w[
          data-src data-aspect data-height-offset data-width-offset
        ].freeze
        ATTRIBUTES = %w[class] + DATA_ATTRIBUTES
      end
    end
  end
end
