require "active_support/core_ext/string/strip"

describe Qiita::Markdown::SummaryProcessor do
  describe "#call" do
    subject(:html) do
      result[:output].to_s
    end

    let(:context) do
      { hostname: "example.com" }
    end

    let(:markdown) do
      fail NotImplementedError
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

      it "returns a Hash with HTML output and other metadata but no codes" do
        expect(result[:mentioned_usernames]).to be_an Array
        expect(result[:output]).to be_a Nokogiri::HTML::DocumentFragment
        expect(result).not_to have_key(:codes)
      end
    end

    context "with HTML-characters" do
      let(:markdown) do
        "<>&"
      end

      it "sanitizes them" do
        should eq <<-EOS.strip_heredoc
          &lt;&gt;&amp;
        EOS
      end
    end

    context "with code" do
      let(:markdown) do
        <<-EOS.strip_heredoc
          ```ruby
          puts 'hello world'
          ```
        EOS
      end

      it "returns simple code element" do
        should eq <<-EOS.strip_heredoc
          <code>puts 'hello world'
          </code>
        EOS
      end
    end

    context "with emoji" do
      let(:markdown) do
        ":+1:"
      end

      it "replaces it with img element" do
        should include("img")
      end
    end

    context "with image" do
      let(:markdown) do
        <<-EOS.strip_heredoc
          ![Qiita](http://qiita.com/icons/favicons/public/apple-touch-icon.png)
        EOS
      end

      it "removes it" do
        expect(html.strip).to be_empty
      end
    end

    context "with line breaks" do
      let(:markdown) do
        <<-EOS.strip_heredoc
          foo
          bar
        EOS
      end

      it "removes them" do
        should eq <<-EOS.strip_heredoc
          foo
          bar
        EOS
      end
    end

    context "with paragraphs" do
      let(:markdown) do
        <<-EOS.strip_heredoc
          Lorem ipsum dolor sit amet.

          Consectetur adipisicing elit.
        EOS
      end

      it "flattens them" do
        should eq <<-EOS.strip_heredoc
          Lorem ipsum dolor sit amet.

          Consectetur adipisicing elit.
        EOS
      end
    end

    context "with normal list items" do
      let(:markdown) do
        <<-EOS.strip_heredoc
          - foo
          - bar
        EOS
      end

      it "flattens them" do
        should eq <<-EOS.strip_heredoc

          foo
          bar

        EOS
      end
    end

    context "with task list items" do
      let(:markdown) do
        <<-EOS.strip_heredoc
          - [ ] foo
          - [x] bar
        EOS
      end

      it "flattens them without converting to checkboxes" do
        should eq <<-EOS.strip_heredoc

          [ ] foo
          [x] bar

        EOS
      end
    end

    context "with table" do
      let(:markdown) do
        <<-EOS.strip_heredoc
          | a | b | c |
          |---|---|---|
          | a | b | c |
        EOS
      end

      it "removes it entirely" do
        expect(html.strip).to be_empty
      end
    end

    context "with a simple long document" do
      before do
        context[:truncate] = { length: 10 }
      end

      let(:markdown) do
        <<-EOS.strip_heredoc
          Lorem ipsum dolor sit amet.
        EOS
      end

      it "truncates it to the specified length" do
        should eq "Lorem ips…"
      end
    end

    context "with a long document consisting of nested elements" do
      before do
        context[:truncate] = { length: 12 }
      end

      let(:markdown) do
        <<-EOS.strip_heredoc
          _[Example](http://example.com/) is **a technical knowledge sharing and collaboration platform for programmers**._
        EOS
      end

      it "truncates it while honoring the document structure" do
        should eq '<em><a href="http://example.com/">Example</a> is <strong>…</strong></em>'
      end
    end

    context "with a long document including consecutive whitespaces" do
      before do
        context[:truncate] = { length: 10 }
      end

      let(:markdown) do
        <<-EOS.strip_heredoc
          **12**   4 [ 6](http://example.com/)_7
          9_ 123
        EOS
      end

      it "truncates it while counting the consecutive whilespaces as one" do
        should eq "<strong>12</strong>   4 <a href=\"http://example.com/\"> 6</a><em>7\n9</em>…"
      end
    end

    context "with truncate: { omission: nil } context" do
      before do
        context[:truncate] = { length: 10, omission: nil }
      end

      let(:markdown) do
        <<-EOS.strip_heredoc
          Lorem ipsum dolor sit amet.
        EOS
      end

      it "does not add extra omission text" do
        should eq "Lorem ipsu"
      end
    end

    context "with mention" do
      let(:markdown) do
        <<-EOS.strip_heredoc
          @alice
        EOS
      end

      it "replaces mention with link" do
        should eq %{<a href="/alice" class="user-mention js-hovercard" title="alice" data-hovercard-target-type="user" data-hovercard-target-name="alice">@alice</a>\n}
      end
    end

    context "with footenote syntax" do
      let(:markdown) do
        <<-EOS.strip_heredoc
          [^1]
          [^1]: test
        EOS
      end

      it "does not generate footnote elements by default" do
        should eq <<-EOS.strip_heredoc
          <a href="test">^1</a>
        EOS
      end
    end
  end
end
