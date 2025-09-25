# frozen_string_literal: true

describe Qiita::Markdown::Filters::InlineMath do
  subject(:filter) do
    described_class.new(html)
  end

  context "with dollar signs" do
    let(:html) do
      <<~HTML
        <div>
          $<code>A = B</code>$
        </div>
      HTML
    end

    it "replaces <code> to <span> with dollars" do
      expect(filter.call.to_html).to eq(
        <<~HTML,
          <div>
            <span>$A = B$</span>
          </div>
        HTML
      )
    end
  end

  context "with dollar signs with surrounding text" do
    let(:html) do
      <<~HTML
        <div>
          Some text before$<code>A = B</code>$Some text after
        </div>
      HTML
    end

    it "replaces <code> to <span> with dollars" do
      expect(filter.call.to_html).to eq(
        <<~HTML,
          <div>
            Some text before<span>$A = B$</span>Some text after
          </div>
        HTML
      )
    end
  end

  context "with double dollar signs" do
    let(:html) do
      <<~HTML
        <div>
          $$
          <code>A = B</code>
          $$
        </div>
      HTML
    end

    it "does not replace <code>" do
      expect(filter.call.to_html).to eq(html)
    end
  end

  context "without dollar signs" do
    let(:html) do
      <<~HTML
        <div>
          <code>A = B</code>
        </div>
      HTML
    end

    it "does not replace <code>" do
      expect(filter.call.to_html).to eq(html)
    end
  end
end
