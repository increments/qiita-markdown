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
  end
end
