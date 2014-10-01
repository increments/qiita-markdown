module Qiita
  module Markdown
    module Filters
      # 1. Adds :mentioned_usernames into result Hash as Array of String.
      # 2. Replaces @mention with link.
      class Mention < HTML::Pipeline::MentionFilter
        # Overrides HTML::Pipeline::MentionFilter's constant.
        # Allows "_" instead of "-" in username pattern.
        MentionPattern = /
          (?:^|\W)
          @((?>[a-z0-9][a-z0-9_]*))
          (?!\/)
          (?=
            \.+[ \t\W]|
            \.+$|
            [^0-9a-zA-Z_.]|
            $
          )
        /ix

        # @note Overrides to use overridden MentionPattern and to disable MentionLogins.
        def self.mentioned_logins_in(text)
          text.gsub(self::MentionPattern) do |match|
            yield match, $1, false
          end
        end

        # @note Override to change HTML template.
        def link_to_mentioned_user(name)
          result[:mentioned_usernames] |= [name]
          url = File.join(base_url, name)
          %[<a href="#{url}" class="user-mention" target="_blank" title="#{name}">@#{name}</a>]
        end
      end
    end
  end
end
