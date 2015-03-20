module Qiita
  module Markdown
    module Filters
      # 1. Adds :mentioned_usernames into result Hash as Array of String.
      # 2. Replaces @mention with link.
      #
      # You can pass :allowed_usernames context to limit mentioned usernames.
      class Mention < HTML::Pipeline::MentionFilter
        MENTION_PATTERN = /
          (?:^|\W)
          @((?>[\w][\w-]{1,30}\w(?:@github)?))
          (?!\/)
          (?=
            \.+[ \t\W]|
            \.+$|
            [^0-9a-zA-Z_.]|
            $
          )
        /ix

        def call
          restore_wrongly_emphasized_mentions
          super
        end

        # @note Override to use customized MentionPattern and allowed_usernames logic.
        def mention_link_filter(text, _, _)
          text.gsub(MENTION_PATTERN) do |match|
            name = $1
            if allowed_usernames && !allowed_usernames.include?(name)
              match
            else
              result[:mentioned_usernames] |= [name]
              url = File.join(base_url, name)
              match.sub(
                "@#{name}",
                %[<a href="#{url}" class="user-mention" title="#{name}">@#{name}</a>]
              )
            end
          end
        end

        private

        # Given a user @foo_ and the following markdown:
        #
        #   _symbol @foo_
        #
        # The `@foo_` should be treated as a mention but Redcarpet parses it as an emphasis,
        # so we restore the original source here.
        def restore_wrongly_emphasized_mentions
          doc.search("em").each do |node|
            last_child = node.children.last
            next if !last_child.text? || !last_child.text.match(MENTION_PATTERN)
            node.prepend_child("_")
            node.add_child("_")
            node.replace(node.children)
          end
        end

        def allowed_usernames
          context[:allowed_usernames]
        end
      end
    end
  end
end
