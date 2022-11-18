# frozen_string_literal: true

describe Qiita::Markdown::Filters::Checkbox do
  subject(:filter) do
    described_class.new(input_html)
  end

  context "with checkbox" do
    let(:input_html) do
      <<~HTML
        <li>[ ] a</li>
        <li>[x] a</li>
      HTML
    end

    let(:output_html) do
      <<~HTML
        <li class="task-list-item">
        <input type="checkbox" class="task-list-item-checkbox" disabled>a</li>
        <li class="task-list-item">
        <input type="checkbox" class="task-list-item-checkbox" checked disabled>a</li>
      HTML
    end

    it "replaces checkboxes" do
      expect(filter.call.to_s).to eq(output_html)
    end

    context "when list is loose" do
      let(:input_html) do
        <<~HTML
          <li>
          <p>[ ] a</p>
          </li>
          <li>
          <p>[x] b</p>
          </li>
        HTML
      end

      let(:output_html) do
        <<~HTML
          <li class="task-list-item">
          <p><input type="checkbox" class="task-list-item-checkbox" disabled>a</p>
          </li>
          <li class="task-list-item">
          <p><input type="checkbox" class="task-list-item-checkbox" checked disabled>b</p>
          </li>
        HTML
      end

      it "replaces checkboxes" do
        expect(filter.call.to_s).to eq(output_html)
      end
    end

    context "when input html has many spaces after checkbox mark" do
      let(:input_html) do
        <<~HTML
          <li>[ ]    a</li>
          <li>[x]    a</li>
        HTML
      end

      it "replaces checkboxes and remove spaces" do
        expect(filter.call.to_s).to eq(output_html)
      end
    end
  end
end
