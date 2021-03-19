module Qiita
  module Markdown
    module Transformers
      class FilterScript
        URL_WHITE_LIST = [
          Embed::CodePen::SCRIPT_URLS,
          Embed::Tweet::SCRIPT_URL,
          Embed::SpeekerDeck::SCRIPT_URLS,
        ].flatten.freeze

        HOST_WHITE_LIST = [
          Embed::Asciinema::SCRIPT_HOST,
        ].flatten.freeze

        def self.call(*args)
          new(*args).transform
        end

        def initialize(env)
          @env = env
        end

        def transform
          if name == "script"
            if URL_WHITE_LIST.include?(node["src"]) || HOST_WHITE_LIST.include?(host_of(node["src"]))
              node["async"] = "async" unless node.attributes.key?("async")
              node.children.unlink
            else
              node.unlink
            end
          end
        end

        private

        def name
          @env[:node_name]
        end

        def node
          @env[:node]
        end

        def host_of(url)
          if url
            scheme = URI.parse(url).scheme
            Addressable::URI.parse(url).host if ["http", "https"].include? scheme
          end
        rescue Addressable::URI::InvalidURIError, URI::InvalidURIError
          nil
        end
      end
    end
  end
end
