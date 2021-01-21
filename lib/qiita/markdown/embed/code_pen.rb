module Qiita
  module Markdown
    module Embed
      module CodePen
        SCRIPT_URLS = [
          "https://production-assets.codepen.io/assets/embed/ei.js",
          "https://static.codepen.io/assets/embed/ei.js",
          "https://cpwebassets.codepen.io/assets/embed/ei.js",
        ]
        CLASS_NAME = %w[codepen]
        DATA_ATTRIBUTES = %w[
          data-active-link-color data-active-tab-color data-animations data-border
          data-border-color data-class data-custom-css-url data-default-tab
          data-embed-version data-height data-link-logo-color data-pen-title
          data-preview data-rerun-position data-show-tab-bar data-slug-hash
          data-tab-bar-color data-tab-link-color data-theme-id data-user
        ]
        ATTRIBUTES = %w[class] + DATA_ATTRIBUTES
      end
    end
  end
end
