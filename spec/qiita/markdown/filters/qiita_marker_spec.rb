# frozen_string_literal: true

describe Qiita::Markdown::Filters::QiitaMarker do
  subject(:filter) { described_class.new(markdown, context) }

  let(:context) { nil }

  context "with footnotes" do
    let(:markdown) do
      <<~MD
        foo [^1]
        [^1]: bar
      MD
    end

    it "renders footnotes" do
      expect(filter.call.to_s).to include('class="footnotes"')
    end

    context "and disable footnotes option" do
      let(:context) do
        {
          markdown: {
            footnotes: false,
          },
        }
      end

      it "does not render footnotes" do
        expect(filter.call.to_s).not_to include('class="footnotes"')
      end
    end
  end

  context "with sourcepos" do
    let(:markdown) do
      <<~MD
        foo bar
      MD
    end

    it "does not render HTML containing data-sourcepos" do
      expect(filter.call.to_s).not_to include("data-sourcepos")
    end

    context "and enable sourcepos option" do
      let(:context) do
        {
          markdown: {
            sourcepos: true,
          },
        }
      end

      it "renders HTML containing data-sourcepos" do
        expect(filter.call.to_s).to include("data-sourcepos")
      end
    end
  end
end
