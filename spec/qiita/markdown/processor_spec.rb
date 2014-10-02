require "active_support/core_ext/string/strip"

describe Qiita::Markdown::Processor do
  describe "#call" do
    subject do
      result[:output].to_s
    end

    let(:markdown) do
      raise NotImplementedError
    end

    let(:result) do
      described_class.new.call(markdown)
    end

    context "with valid condition" do
      let(:markdown) do
        <<-EOS.strip_heredoc
          # example
        EOS
      end

      it "returns a Hash with HTML output and other metadata" do
        expect(result[:codes]).to be_an Array
        expect(result[:mentioned_usernames]).to be_an Array
        expect(result[:output]).to be_a Nokogiri::HTML::DocumentFragment
      end
    end

    context "with HTML-characters" do
      let(:markdown) do
        "<>&"
      end

      it "sanitizes them" do
        should eq <<-EOS.strip_heredoc
          <p>&lt;&gt;&amp;</p>
        EOS
      end
    end

    context "with code" do
      let(:markdown) do
        <<-EOS.strip_heredoc
          ```foo.rb
          puts 'hello world'
          ```
        EOS
      end

      it "returns detected codes" do
        expect(result[:codes]).to eq [
          {
            code: "puts 'hello world'\n",
            filename: "foo.rb",
            language: "ruby",
          },
        ]
      end
    end

    context "with undefined but aliased language" do
      let(:markdown) do
        <<-EOS.strip_heredoc
          ```zsh
          true
          ```
        EOS
      end

      it "returns aliased language name" do
        expect(result[:codes]).to eq [
          {
            code: "true\n",
            filename: nil,
            language: "bash",
          },
        ]
      end
    end

    context "with mention" do
      let(:markdown) do
        "@alice"
      end

      it "replaces mention with link" do
        should include(<<-EOS.strip_heredoc.rstrip)
          <a href="/alice" class="user-mention" target="_blank" title="alice">@alice</a>
        EOS
      end
    end

    context "with mentions in complex patterns" do
      let(:markdown) do
        <<-EOS.strip_heredoc
          @alice

          ```
            @bob
          ```

          @charlie/@dave
          @ell_en
          @frank-san
          @Isaac
          @justin
          @justin
        EOS
      end

      it "extracts mentions correctly" do
        expect(result[:mentioned_usernames]).to eq %w[
          alice
          dave
          ell_en
          frank
          Isaac
          justin
        ]
      end
    end

    context "with normal link" do
      let(:markdown) do
        "[](/example)"
      end

      it "creates link for that" do
        should eq <<-EOS.strip_heredoc
          <p><a href="/example"></a></p>
        EOS
      end
    end

    context "with anchor link" do
      let(:markdown) do
        "[](#example)"
      end

      it "creates link for that" do
        should eq <<-EOS.strip_heredoc
          <p><a href="#example"></a></p>
        EOS
      end
    end

    context "with javascript: link" do
      let(:markdown) do
        "[](javascript:alert(1))"
      end

      it "removes that link by creating empty a element" do
        should eq <<-EOS.strip_heredoc
          <p><a></a></p>
        EOS
      end
    end

    context "with mailto: link" do
      let(:markdown) do
        "[](mailto:info@example.com)"
      end

      it "removes that link by creating empty a element" do
        should eq <<-EOS.strip_heredoc
          <p><a></a></p>
        EOS
      end
    end

    context "with emoji" do
      let(:markdown) do
        ":+1:"
      end

      it "replaces it with img element" do
        should eq <<-EOS.strip_heredoc
          <p><img class="emoji" title=":+1:" alt=":+1:" src="/images/emoji/%2B1.png" height="20" width="20" align="absmiddle"></p>
        EOS
      end
    end

    context "with emoji in pre or code element" do
      let(:markdown) do
        <<-EOS.strip_heredoc
          ```
          :+1:
          ```
        EOS
      end

      it "does not replace it" do
        should eq <<-EOS.strip_heredoc
          <pre><code>:+1:
          </code></pre>
        EOS
      end
    end
  end
end
