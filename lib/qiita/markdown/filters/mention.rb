module Qiita
  module Markdown
    module Filters
      # 1. Adds :mentioned_usernames into result Hash as Array of String.
      # 2. Replaces @mention with link.
      #
      # You can pass :allowed_usernames context to limit mentioned usernames.
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

        # @note Override to use customized MentionPattern and allowed_usernames logic.
        def mention_link_filter(text, _, _)
          text.gsub(MentionPattern) do |match|
            name = $1
            if allowed_usernames && !allowed_usernames.include?(name)
              match
            else
              result[:mentioned_usernames] |= [name]
              url = File.join(base_url, name)
              match.sub(
                "@#{name}",
                %[<a href="#{url}" class="user-mention" target="_blank" title="#{name}">@#{name}</a>]
              )
            end
          end
        end

        private

        def allowed_usernames
          context[:allowed_usernames]
        end
      end
    end
  end
end
