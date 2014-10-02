require "active_support/core_ext/string/strip"

describe Qiita::Markdown::Processor do
  describe "#call" do
    subject do
      result[:output].to_s
    end

    let(:context) do
      {}
    end

    let(:markdown) do
      raise NotImplementedError
    end

    let(:result) do
      described_class.new(context).call(markdown)
    end

    context "with valid condition" do
      let(:markdown) do
        <<-EOS.strip_heredoc
          example
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

    context "with headings" do
      let(:markdown) do
        <<-EOS.strip_heredoc
          # a
          ## a
          ### a
          ### a
        EOS
      end

      it "adds ID for ToC" do
        should eq <<-EOS.strip_heredoc
          <h1>
          <span id="a" class="fragment"></span><a href="#a"><i class="fa fa-link"></i></a>a</h1>

          <h2>
          <span id="a-1" class="fragment"></span><a href="#a-1"><i class="fa fa-link"></i></a>a</h2>

          <h3>
          <span id="a-2" class="fragment"></span><a href="#a-2"><i class="fa fa-link"></i></a>a</h3>

          <h3>
          <span id="a-3" class="fragment"></span><a href="#a-3"><i class="fa fa-link"></i></a>a</h3>
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

    context "with script element" do
      let(:markdown) do
        <<-EOS.strip_heredoc
          <script>alert(1)</script>
        EOS
      end

      it "removes script element" do
        should eq "\n"
      end
    end

    context "with script context" do
      before do
        context[:script] = true
      end

      let(:markdown) do
        <<-EOS.strip_heredoc
          <script>alert(1)</script>
        EOS
      end

      it "allows script element" do
        should eq markdown
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
          @fran-k
          @Isaac
          @justin
          @justin
          @mallory@github
          @#{?o * 33}
          @oo
        EOS
      end

      it "extracts mentions correctly" do
        expect(result[:mentioned_usernames]).to eq %W[
          alice
          dave
          ell_en
          fran-k
          Isaac
          justin
          mallory@github
        ]
      end
    end

    context "with allowed_usernames context" do
      before do
        context[:allowed_usernames] = ["alice"]
      end

      let(:markdown) do
        <<-EOS.strip_heredoc
          @alice
          @bob
        EOS
      end

      it "limits mentions to allowed usernames" do
        expect(result[:mentioned_usernames]).to eq ["alice"]
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
