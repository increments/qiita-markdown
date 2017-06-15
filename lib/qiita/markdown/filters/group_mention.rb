module Qiita
  module Markdown
    module Filters
      class GroupMention < HTML::Pipeline::Filter
        # @note Override
        def call
          if context[:group_mention_url_generator]
            result[:mentioned_groups] ||= []
            doc.search(".//text()").each do |node|
              mentionable_node = MentionableNode.new(node, context[:group_mention_url_generator])
              unless mentionable_node.ignorable?
                result[:mentioned_groups] |= mentionable_node.groups
                node.replace(mentionable_node.replaced_html)
              end
            end
          end
          doc
        end

        class MentionableNode
          GROUP_IDENTIFIER_PATTERN = %r{
            (?:^|\W)
            @((?>[a-z\d][a-z\d-]{2,31}))
            \/
            ([A-Za-z\d][A-Za-z\d-]{0,14}[A-Za-z\d])
            (?!\/)
            (?=
              \.+[ \t\W]|
              \.+$|
              [^0-9a-zA-Z_.]|
              $
            )
          }x

          IGNORED_ANCESTOR_ELEMENT_NAMES = %w[
            a
            blockquote
            code
            pre
            style
          ].freeze

          # @param node [Nokogiri::XML::Node]
          # @param group_mention_url_generator [Proc]
          def initialize(node, group_mention_url_generator)
            @group_mention_url_generator = group_mention_url_generator
            @node = node
          end

          # @return [Array<Hash>]
          def groups
            @groups ||= []
          end

          # @return [false, true]
          def ignorable?
            !has_at_mark? || has_any_ignored_ancestor? || !replaced?
          end

          # @return [String]
          def replaced_html
            @replaced_html ||= html.gsub(GROUP_IDENTIFIER_PATTERN) do |string|
              team_url_name = ::Regexp.last_match(1)
              group_url_name = ::Regexp.last_match(2)
              group = { group_url_name: group_url_name, team_url_name: team_url_name }
              groups << group
              string.sub(
                "@#{team_url_name}/#{group_url_name}",
                %(<a href="#{@group_mention_url_generator.call(group)}">) +
                  %(@#{team_url_name}/#{group_url_name}</a>),
              )
            end
          end

          private

          # @return [false, true]
          def has_any_ignored_ancestor?
            @node.ancestors.any? do |node|
              IGNORED_ANCESTOR_ELEMENT_NAMES.include?(node.name.downcase)
            end
          end

          # @return [false, true]
          def has_at_mark?
            html.include?("@")
          end

          # @return [String]
          def html
            @html ||= @node.to_html
          end

          # @return [false, true]
          def replaced?
            html != replaced_html
          end
        end
      end
    end
  end
end
