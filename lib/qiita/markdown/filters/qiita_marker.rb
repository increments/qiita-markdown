# frozen_string_literal: true

module Qiita
  module Markdown
    module Filters
      class QiitaMarker < ::HTML::Pipeline::TextFilter
        DEFAULT_OPTIONS = {
          footnotes: true,
          sourcepos: false,
        }.freeze

        # @return [Nokogiri::HTML::DocumentFragment]
        def call
          ::Nokogiri::HTML.fragment(render(@text))
        end

        private

        # @param text [String]
        # @return [String]
        def render(text)
          ::QiitaMarker.render_html(text, qiita_marker_options, qiita_marker_extensions)
        end

        def qiita_marker_options
          options_to_append = (options[:footnotes] ? [:FOOTNOTES] : [])
                              .concat(options[:sourcepos] ? [:SOURCEPOS] : [])
          @qiita_marker_options ||= %i[
            HARDBREAKS
            UNSAFE
            LIBERAL_HTML_TAG
            STRIKETHROUGH_DOUBLE_TILDE
            TABLE_PREFER_STYLE_ATTRIBUTES
            CODE_DATA_METADATA
            MENTION_NO_EMPHASIS
            AUTOLINK_CLASS_NAME
          ].concat(options_to_append)
        end

        def qiita_marker_extensions
          @qiita_marker_extensions ||= %i[
            table
            strikethrough
            autolink
            custom_block
          ]
        end

        def options
          @options ||= DEFAULT_OPTIONS.merge(context[:markdown] || {})
        end
      end
    end
  end
end
