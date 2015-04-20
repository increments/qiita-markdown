require "active_support/core_ext/string/strip"

describe Qiita::Markdown::Greenmat::HTMLRenderer do
  let(:renderer) { described_class.new(extension) }
  let(:extension) { {} }
  let(:greenmat) { ::Greenmat::Markdown.new(renderer) }
  subject(:rendered_html) { greenmat.render(markdown) }

  describe "headings" do
    let(:markdown) do
      <<-EOS.strip_heredoc
        # a
        ## a
        ### a
        ### a
      EOS
    end

    context "with :with_toc_data extension" do
      let(:extension) { { with_toc_data: true } }

      it "renders headings with ToC anchor" do
        should eq <<-EOS.strip_heredoc

          <h1><span id="a" class="fragment"></span><a href="#a"><i class="fa fa-link"></i></a>a</h1>

          <h2><span id="a-1" class="fragment"></span><a href="#a-1"><i class="fa fa-link"></i></a>a</h2>

          <h3><span id="a-2" class="fragment"></span><a href="#a-2"><i class="fa fa-link"></i></a>a</h3>

          <h3><span id="a-3" class="fragment"></span><a href="#a-3"><i class="fa fa-link"></i></a>a</h3>
        EOS
      end

      context "and heading title including special HTML characters" do
        let(:markdown) do
          <<-EOS.strip_heredoc
            # <b>R&amp;B</b>
          EOS
        end

        it "generates fragment identifier by sanitizing the characters in the title" do
          should eq <<-EOS.strip_heredoc

            <h1><span id="rb" class="fragment"></span><a href="#rb"><i class="fa fa-link"></i></a><b>R&amp;B</b></h1>
          EOS
        end
      end
    end

    context "without :with_toc_data extension" do
      let(:extension) { { with_toc_data: false } }

      it "renders headings without ToC anchor" do
        should eq <<-EOS.strip_heredoc

          <h1>a</h1>

          <h2>a</h2>

          <h3>a</h3>

          <h3>a</h3>
        EOS
      end
    end
  end
end
