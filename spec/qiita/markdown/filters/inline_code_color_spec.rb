describe Qiita::Markdown::Filters::InlineCodeColor do
  subject(:filter) do
    described_class.new(html)
  end

  let(:html) do
    "<p><code>#{color}</code></p>"
  end

  shared_examples "adds span element for its color" do |color|
    let(:color) { color }

    it "adds span element for its color" do
      expect(filter.call.to_s).to eq(%(<p><code>#{color}<span class="inline-code-color" style="background-color: #{color};"></span></code></p>))
    end
  end

  shared_examples "does not add span element" do |color|
    let(:color) { color }

    it "does not add span element" do
      expect(filter.call.to_s).to eq(%(<p><code>#{color}</code></p>))
    end
  end

  context "when contents of code is hexadecimal color" do
    %w[
      #000
      #f03
      #F03
      #fff
      #FFF
      #000000
      #ff0033
      #FF0033
      #ffffff
      #FFFFFF
    ].each do |color|
      context "when contents of code is #{color}" do
        include_examples "adds span element for its color", color
      end
    end
  end

  context "when contents of code is not hexadecimal color" do
    %w[
      #-1-1-1
      #ggg
      #GGG
      #gggggg
      #gggGGG
      #GGGGGG
    ].each do |color|
      context "when contents of code is #{color}" do
        include_examples "does not add span element", color
      end
    end
  end

  context "when contents of code is rgb color" do
    [
      "rgb(255,0,51)",
      "rgb(255, 0, 51)",
      "rgb(100%,0%,20%)",
      "rgb(100%, 0%, 20%)",
      "rgb(255,0,0,0.4)",
      "rgb(255, 0, 0, 0.4)",
      "rgb(255,0,0,.4)",
      "rgb(255, 0, 0, .4)",
      "rgb(255,0,0,40%)",
      "rgb(255, 0, 0, 40%)",
      "rgb(255 0 0/0.4)",
      "rgb(255 0 0 / 0.4)",
      "rgb(255 0 0/.4)",
      "rgb(255 0 0 / .4)",
      "rgb(255 0 0/40%)",
      "rgb(255 0 0 / 40%)",
    ].each do |color|
      context "when contents of code is #{color}" do
        include_examples "adds span element for its color", color
      end
    end
  end

  context "when contents of code is not rgb color" do
    [
      "rgb(0)",
      "rgb(0, 0)",
      "rgb(0, 0, 0%)",
      "rgb(0, 0, 0, 0, 0)",
    ].each do |color|
      context "when contents of code is #{color}" do
        include_examples "does not add span element", color
      end
    end
  end

  context "when contents of code is rgba color" do
    [
      "rgba(255,0,0,0)",
      "rgba(255, 0, 0, 0)",
      "rgba(255,0,0,0.1)",
      "rgba(255, 0, 0, 0.1)",
      "rgba(255,0,0,.4)",
      "rgba(255, 0, 0, .4)",
      "rgba(255,0,0,1)",
      "rgba(255, 0, 0, 1)",
      "rgba(255 0 0/0.4)",
      "rgba(255 0 0 / 0.4)",
      "rgba(255 0 0/.4)",
      "rgba(255 0 0 / .4)",
      "rgba(255 0 0/40%)",
      "rgba(255 0 0 / 40%)",
    ].each do |color|
      context "when contents of code is #{color}" do
        include_examples "adds span element for its color", color
      end
    end
  end

  context "when contents of code is not rgba color" do
    [
      "rgba(0)",
      "rgba(0, 0)",
      "rgba(0, 0, 0%)",
      "rgba(0, 0, 0, 0, 0)",
    ].each do |color|
      context "when contents of code is #{color}" do
        include_examples "does not add span element", color
      end
    end
  end

  context "when contents of code is hsl color" do
    [
      "hsl(0,100%,50%)",
      "hsl(0, 100%, 50%)",
      "hsl(360,100%,50%)",
      "hsl(360, 100%, 50%)",
      "hsl(120 60% 70%)",
      "hsl(120deg 60% 70%)",
      "hsl(240,100%,50%,0.05)",
      "hsl(240, 100%, 50%, 0.05)",
      "hsl(240,100%,50%,.05)",
      "hsl(240, 100%, 50%, .05)",
      "hsl(240,100%,50%,5%)",
      "hsl(240, 100%, 50%, 5%)",
      "hsl(240 100% 50%/0.05)",
      "hsl(240 100% 50% / 0.05)",
      "hsl(240 100% 50%/.05)",
      "hsl(240 100% 50% / .05)",
      "hsl(240 100% 50%/5%)",
      "hsl(240 100% 50% / 5%)",
    ].each do |color|
      context "when contents of code is #{color}" do
        include_examples "adds span element for its color", color
      end
    end
  end

  context "when contents of code is not hsl color" do
    [
      "hsl(0)",
      "hsl(0, 0)",
      "hsl(0, 0, 0)",
      "hsl(0, 0, 0, 0)",
    ].each do |color|
      context "when contents of code is #{color}" do
        include_examples "does not add span element", color
      end
    end
  end

  context "when contents of code is hsla color" do
    [
      "hsla(240,100%,50%,0.05)",
      "hsla(240, 100%, 50%, 0.05)",
      "hsla(240,100%,50%,.05)",
      "hsla(240, 100%, 50%, .05)",
      "hsla(240 100% 50%/0.05)",
      "hsla(240 100% 50% / 0.05)",
      "hsla(240 100% 50%/5%)",
      "hsla(240 100% 50% / 5%)",
      "hsla(240deg 100% 50% / 5%)",
      "hsla(240deg,100%,50%, 0.4)",
    ].each do |color|
      context "when contents of code is #{color}" do
        include_examples "adds span element for its color", color
      end
    end

    context "when contents of code is not hsla color" do
      [
        "hsla(0)",
        "hsla(0, 0)",
        "hsla(0, 0, 0)",
        "hsla(0, 0, 0, 0)",
      ].each do |color|
        context "when contents of code is #{color}" do
          include_examples "does not add span element", color
        end
      end
    end
  end
end
