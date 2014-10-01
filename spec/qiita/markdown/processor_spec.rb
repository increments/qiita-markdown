require "active_support/core_ext/string/strip"

describe Qiita::Markdown::Processor do
  describe "#call" do
    subject do
      described_class.new.call(markdown_text)
    end

    let(:markdown_text) do
      <<-EOS.strip_heredoc
        # h1
        ```foo.rb
        puts "hello world"
        ```
      EOS
    end

    context "with valid condition" do
      it "returns a Hash with HTML output and other metadata" do
        should be_a Hash
        expect(subject[:mentioned_usernames]).to be_an Array
        expect(subject[:output]).to be_a Nokogiri::HTML::DocumentFragment
      end
    end

    context "with code" do
      it "returns detected codes" do
        expect(subject[:codes]).to eq [
          {
            code: %<puts "hello world"\n>,
            filename: "foo.rb",
            language: "ruby",
          },
        ]
      end
    end

    context "with mention" do
      let(:markdown_text) do
        "@alice"
      end

      it "replaces mention with link" do
        expect(subject[:output].to_s).to include(<<-EOS.strip_heredoc.rstrip)
          <a href="/alice" class="user-mention" target="_blank" title="alice">@alice</a>
        EOS
      end
    end

    context "with mentions in complex patterns" do
      let(:markdown_text) do
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
        expect(subject[:mentioned_usernames]).to eq %w[
          alice
          dave
          ell_en
          frank
          Isaac
          justin
        ]
      end
    end
  end
end
