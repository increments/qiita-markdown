require "active_support/core_ext/string/strip"

describe Qiita::Markdown::Greenmat::HTMLToCRenderer do
  let(:renderer) { described_class.new(extension) }
  let(:extension) { {} }
  let(:greenmat) { ::Greenmat::Markdown.new(renderer) }
  subject(:rendered_html) { greenmat.render(markdown) }

  context "with duplicated heading names" do
    let(:markdown) do
      <<-EOS.strip_heredoc
        # a
        ## a
        ### a
        ### a
      EOS
    end

    it "renders ToC anchors with unique ids" do
      should eq <<-EOS.strip_heredoc
        <ul>
        <li>
        <a href="#a">a</a>
        <ul>
        <li>
        <a href="#a-1">a</a>
        <ul>
        <li>
        <a href="#a-2">a</a>
        </li>
        <li>
        <a href="#a-3">a</a>
        </li>
        </ul>
        </li>
        </ul>
        </li>
        </ul>
      EOS
    end
  end

  context "with a document starting with level 2 heading" do
    let(:markdown) do
      <<-EOS.strip_heredoc
        ## a
        ### a
        ## a
      EOS
    end

    it "offsets the heading levels" do
      should eq <<-EOS.strip_heredoc
        <ul>
        <li>
        <a href="#a">a</a>
        <ul>
        <li>
        <a href="#a-1">a</a>
        </li>
        </ul>
        </li>
        <li>
        <a href="#a-2">a</a>
        </li>
        </ul>
      EOS
    end
  end

  context "with a document starting with level 2 heading but includes level 1 heading at the end" do
    let(:markdown) do
      <<-EOS.strip_heredoc
        ## a
        ### a
        # a
      EOS
    end

    it "does not generate invalid list structure" do
      should eq <<-EOS.strip_heredoc
        <ul>
        <li>
        <a href="#a">a</a>
        <ul>
        <li>
        <a href="#a-1">a</a>
        </li>
        </ul>
        </li>
        <li>
        <a href="#a-2">a</a>
        </li>
        </ul>
      EOS
    end
  end

  context "with heading title including special HTML characters" do
    let(:markdown) do
      <<-EOS.strip_heredoc
        # <b>R&amp;B</b>
      EOS
    end

    it "generates fragment identifier by sanitizing the characters in the title" do
      should eq <<-EOS.strip_heredoc
        <ul>
        <li>
        <a href="#rb"><b>R&amp;B</b></a>
        </li>
        </ul>
      EOS
    end
  end

  context "with :escape_html extension" do
    let(:extension) { { escape_html: true } }

    let(:markdown) do
      <<-EOS.strip_heredoc
        # <b>R&amp;B</b>
      EOS
    end

    it "escapes special HTML characters in heading title" do
      should eq <<-EOS.strip_heredoc
        <ul>
        <li>
        <a href="#rb">&lt;b&gt;R&amp;amp;B&lt;/b&gt;</a>
        </li>
        </ul>
      EOS
    end
  end

  context "with anchor tag" do
    let(:markdown) do
      <<-EOS.strip_heredoc
        # <a href="#">foo</a>
      EOS
    end

    it "strips anchor tag" do
      should eq <<-EOS.strip_heredoc
        <ul>
        <li>
        <a href="#foo">foo</a>
        </li>
        </ul>
      EOS
    end
  end

  context "with <ol> tag" do
    let(:markdown) do
      <<-EOS.strip_heredoc
        # <ol>foo</ol>
      EOS
    end

    it "strips <ol> tag" do
      should eq <<-EOS.strip_heredoc
        <ul>
        <li>
        <a href="#foo">foo</a>
        </li>
        </ul>
      EOS
    end
  end

  context "with <ul> tag" do
    let(:markdown) do
      <<-EOS.strip_heredoc
        # <ul>foo</ul>
      EOS
    end

    it "strips <ul> tag" do
      should eq <<-EOS.strip_heredoc
        <ul>
        <li>
        <a href="#foo">foo</a>
        </li>
        </ul>
      EOS
    end
  end

  context "with <li> tag" do
    let(:markdown) do
      <<-EOS.strip_heredoc
        # <li>foo</li>
      EOS
    end

    it "strips <li> tag" do
      should eq <<-EOS.strip_heredoc
        <ul>
        <li>
        <a href="#foo">foo</a>
        </li>
        </ul>
      EOS
    end
  end

  context "with <li> tag inside of <ul> tag" do
    let(:markdown) do
      <<-EOS.strip_heredoc
        # <ul><li>foo</li></ul>
      EOS
    end

    it "strips <ul> and <li> tag" do
      should eq <<-EOS.strip_heredoc
        <ul>
        <li>
        <a href="#foo">foo</a>
        </li>
        </ul>
      EOS
    end
  end
end
