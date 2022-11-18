# frozen_string_literal: true

describe Qiita::Markdown::Filters::HeadingAnchor do
  subject(:filter) { described_class.new(html) }

  let(:html) do
    <<~HTML
      <h1>foo</h1>
      <h2>bar</h2>
      <h3>fizz</h3>
      <p>paragraph</p>
      <h4>buzz</h4>
      <h5>hoge</h5>
      <h6>fuga</h6>
      <code>code</code>
    HTML
  end

  it "renders ids" do
    expect(filter.call.to_s).to eq(<<~HTML)
      <h1 id="foo">foo</h1>
      <h2 id="bar">bar</h2>
      <h3 id="fizz">fizz</h3>
      <p>paragraph</p>
      <h4 id="buzz">buzz</h4>
      <h5 id="hoge">hoge</h5>
      <h6 id="fuga">fuga</h6>
      <code>code</code>
    HTML
  end

  context "with headings text is same" do
    let(:html) do
      <<~HTML
        <h1>foo</h1>
        <h2>foo</h2>
        <h3>foo</h3>
        <p>paragraph</p>
        <h4>foo</h4>
        <h5>foo</h5>
        <h6>foo</h6>
        <code>code</code>
      HTML
    end

    it "renders suffixed ids" do
      expect(filter.call.to_s).to eq(<<~HTML)
        <h1 id="foo">foo</h1>
        <h2 id="foo-1">foo</h2>
        <h3 id="foo-2">foo</h3>
        <p>paragraph</p>
        <h4 id="foo-3">foo</h4>
        <h5 id="foo-4">foo</h5>
        <h6 id="foo-5">foo</h6>
        <code>code</code>
      HTML
    end
  end

  context "with characters that cannot included" do
    let(:html) do
      <<~HTML
        <h1>test [foo-bar]</h1>
      HTML
    end

    it "renders id with omitted characters" do
      expect(filter.call.to_s).to eq(<<~HTML)
        <h1 id="test-foo-bar">test [foo-bar]</h1>
      HTML
    end
  end
end
