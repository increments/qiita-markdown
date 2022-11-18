# frozen_string_literal: true

describe Qiita::Markdown::Filters::HtmlToc do
  subject(:filter) { described_class.new(html) }

  context "with headings h1, h2, h3, h4, h5, h6" do
    let(:html) do
      <<~HTML
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

    let(:result) do
      <<~HTML
        <ul>
        <li>
        <a href="#foo">foo</a>
        <ul>
        <li>
        <a href="#bar">bar</a>
        <ul>
        <li>
        <a href="#fizz">fizz</a>
        <ul>
        <li>
        <a href="#buzz">buzz</a>
        <ul>
        <li>
        <a href="#hoge">hoge</a>
        <ul>
        <li>
        <a href="#fuga">fuga</a>
        </li>
        </ul>
        </li>
        </ul>
        </li>
        </ul>
        </li>
        </ul>
        </li>
        </ul>
        </li>
        </ul>
      HTML
    end

    it "renders nested toc" do
      expect(filter.call).to eq(result)
    end
  end

  context "headings are same rank" do
    let(:html) do
      <<~HTML
        <h1 id="foo">foo</h1>
        <h1 id="bar">bar</h1>
        <h1 id="fizz">fizz</h1>
      HTML
    end

    let(:result) do
      <<~HTML
        <ul>
        <li>
        <a href="#foo">foo</a>
        </li>
        <li>
        <a href="#bar">bar</a>
        </li>
        <li>
        <a href="#fizz">fizz</a>
        </li>
        </ul>
      HTML
    end

    it "renders toc of same level" do
      expect(filter.call).to eq(result)
    end
  end

  context "with heading rank going up" do
    let(:html) do
      <<~HTML
        <h1 id="foo">foo</h1>
        <h3 id="bar">bar</h3>
        <h1 id="bazz">bazz</h1>
      HTML
    end

    let(:result) do
      <<~HTML
        <ul>
        <li>
        <a href="#foo">foo</a>
        <ul>
        <li>
        <ul>
        <li>
        <a href="#bar">bar</a>
        </li>
        </ul>
        </li>
        </ul>
        </li>
        <li>
        <a href="#bazz">bazz</a>
        </li>
        </ul>
      HTML
    end

    it "renders toc that the depth goes up" do
      expect(filter.call).to eq(result)
    end
  end

  context "with starting from h2" do
    let(:html) do
      <<~HTML
        <h2 id="bar">bar</h2>
        <h3 id="fizz">fizz</h3>
      HTML
    end

    let(:result) do
      <<~HTML
        <ul>
        <li>
        <a href="#bar">bar</a>
        <ul>
        <li>
        <a href="#fizz">fizz</a>
        </li>
        </ul>
        </li>
        </ul>
      HTML
    end

    it "renders h2 as top level" do
      expect(filter.call).to eq(result)
    end
  end

  context "with some heading rank is higher than first heading" do
    let(:html) do
      <<~HTML
        <h2 id="foo">foo</h2>
        <h3 id="bar">bar</h3>
        <h1 id="fizz">fizz</h1>
        <h2 id="bazz">bazz</h2>
      HTML
    end

    let(:result) do
      <<~HTML
        <ul>
        <li>
        <a href="#foo">foo</a>
        <ul>
        <li>
        <a href="#bar">bar</a>
        </li>
        </ul>
        </li>
        <li>
        <a href="#fizz">fizz</a>
        </li>
        <li>
        <a href="#bazz">bazz</a>
        </li>
        </ul>
      HTML
    end

    it "renders higher rank headings at the same level as the first heading" do
      expect(filter.call).to eq(result)
    end
  end

  context "with include html tag" do
    let(:html) do
      <<~HTML
        <h2 id="foo"><strong>foo</strong></h2>
      HTML
    end

    let(:result) do
      <<~HTML
        <ul>
        <li>
        <a href="#foo">foo</a>
        </li>
        </ul>
      HTML
    end

    it "anchor text does not include html tag" do
      expect(filter.call).to eq(result)
    end
  end

  context "without headings" do
    let(:html) do
      <<~HTML
        <p>paragraph</p>
      HTML
    end

    it "renders empty string" do
      expect(filter.call.to_s).to eq("")
    end
  end
end
