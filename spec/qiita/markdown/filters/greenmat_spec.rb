describe Qiita::Markdown::Filters::Greenmat do
  subject(:filter) do
    described_class.new(markdown)
  end

  context "with headings" do
    let(:markdown) do
      "# foo"
    end

    it "does not generate FontAwesome classes so that we can say that they're inputted by user" do
      expect(filter.call.to_s).to eq(%(\n<h1 id="foo">foo</h1>\n))
    end
  end
end
