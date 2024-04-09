# frozen_string_literal: true

describe Qiita::Markdown::Filters::CodeBlock do
  subject(:filter) { described_class.new(input_html) }

  let(:context) { nil }

  context "without code" do
    let(:input_html) do
      <<~HTML
        <pre>
        </pre>
      HTML
    end

    it "does not change" do
      expect(filter.call.to_s).to eq(input_html)
    end
  end

  context "with code" do
    let(:input_html) do
      <<~HTML
        <pre><code>
        </code></pre>
      HTML
    end

    it "does not change" do
      expect(filter.call.to_s).to eq(input_html)
    end

    context "with data-metadata" do
      let(:input_html) do
        <<~HTML
          <pre><code data-metadata>
          </code></pre>
        HTML
      end

      it "does not change" do
        expect(filter.call.to_s).to eq(input_html)
      end

      context "with data-metadata value" do
        let(:input_html) do
          <<~HTML
            <pre><code data-metadata="ruby">
            </code></pre>
          HTML
        end

        let(:output_html) do
          <<~HTML
            <pre lang="ruby"><code data-metadata="ruby">
            </code></pre>
          HTML
        end

        it "adds lang on pre" do
          expect(filter.call.to_s).to eq(output_html)
        end

        context "with value include filename" do
          let(:input_html) do
            <<~HTML
              <pre><code data-metadata="ruby:abc.rb">
              </code></pre>
            HTML
          end

          let(:output_html) do
            <<~HTML
              <pre filename="abc.rb" lang="ruby"><code data-metadata="ruby:abc.rb">
              </code></pre>
            HTML
          end

          it "adds lang and filename on pre" do
            expect(filter.call.to_s).to eq(output_html)
          end
        end
      end

      context "with data-metadata value like filename" do
        let(:input_html) do
          <<~HTML
            <pre><code data-metadata="abc.rb">
            </code></pre>
          HTML
        end

        let(:output_html) do
          <<~HTML
            <pre filename="abc.rb" lang="ruby"><code data-metadata="abc.rb">
            </code></pre>
          HTML
        end

        it "adds lang and filename on pre" do
          expect(filter.call.to_s).to eq(output_html)
        end
      end

      context "with data-metadata value like filename without extension" do
        let(:input_html) do
          <<~HTML
            <pre><code data-metadata="Dockerfile">
            </code></pre>
          HTML
        end

        let(:output_html) do
          <<~HTML
            <pre lang="Dockerfile"><code data-metadata="Dockerfile">
            </code></pre>
          HTML
        end

        it "adds lang and filename on pre" do
          expect(filter.call.to_s).to eq(output_html)
        end
      end
    end
  end
end
