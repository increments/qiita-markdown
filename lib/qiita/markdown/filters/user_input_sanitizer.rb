# frozen_string_literal: true

module Qiita
  module Markdown
    module Filters
      # Sanitizes user input if :strict context is given.
      class UserInputSanitizer < ::HTML::Pipeline::Filter
        RULE = {
          elements: %w[
            a b blockquote br caption code dd del details div dl dt em font h1 h2 h3 h4 h5 h6
            hr i img ins kbd li ol p pre q rp rt ruby s samp script iframe section strike strong sub
            summary sup table tbody td tfoot th thead tr ul var
          ],
          attributes: {
            "a" => %w[class href rel title id],
            "blockquote" => %w[cite] + Embed::Tweet::ATTRIBUTES,
            "code" => %w[data-metadata],
            "div" => %w[class data-type data-metadata],
            "details" => %w[open],
            "font" => %w[color],
            "h1" => %w[id],
            "h2" => %w[id],
            "h3" => %w[id],
            "h4" => %w[id],
            "h5" => %w[id],
            "h6" => %w[id],
            "img" => %w[alt height src title width],
            "ins" => %w[cite datetime],
            "li" => %w[id],
            "p" => Embed::CodePen::ATTRIBUTES,
            "q" => %w[cite],
            "section" => %w[class],
            "script" => %w[async src id].concat(
              Embed::SpeekerDeck::ATTRIBUTES,
              Embed::Docswell::ATTRIBUTES,
            ),
            "iframe" => %w[
              allowfullscreen
              frameborder
              height
              loading
              marginheight
              marginwidth
              scrolling
              src
              style
              width
            ],
            "sup" => %w[id],
            "td" => %w[colspan rowspan style],
            "th" => %w[colspan rowspan style],
            all: %w[data-sourcepos],
          },
          protocols: {
            "a" => { "href" => ["http", "https", "mailto", :relative] },
            "blockquote" => { "cite" => ["http", "https", :relative] },
            "q" => { "cite" => ["http", "https", :relative] },
          },
          css: {
            properties: %w[text-align border],
          },
          transformers: [
            Transformers::FilterAttributes,
            Transformers::FilterScript,
            Transformers::FilterIframe,
          ],
        }.freeze

        def call
          ::Sanitize.clean_node!(doc, RULE) if context[:strict]
          doc
        end
      end
    end
  end
end
