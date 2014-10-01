require "active_support/core_ext/string/strip"

describe Qiita::Markdown::Processor do
  describe "#call" do
    subject do
      described_class.new.call(markdown_text)
    end

    let(:markdown_text) do
      <<-EOS.strip_heredoc
        # h1
        ```
          puts "hello world"
        ```
      EOS
    end


    it "returns a Hash with HTML output and other metadata" do
      should be_a Hash
    end
  end
end
