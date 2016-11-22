require "active_support/core_ext/string/strip"

describe Qiita::Markdown::Processor do
  describe "#call" do
    subject do
      result[:output].to_s
    end

    let(:context) do
      { hostname: "example.com" }
    end

    let(:markdown) do
      raise NotImplementedError
    end

    let(:result) do
      described_class.new(context).call(markdown)
    end

    context "with valid condition" do
      let(:markdown) do
        <<-EOS.strip_heredoc
          example
        EOS
      end

      it "returns a Hash with HTML output and other metadata" do
        expect(result[:codes]).to be_an Array
        expect(result[:mentioned_usernames]).to be_an Array
        expect(result[:output]).to be_a Nokogiri::HTML::DocumentFragment
      end
    end

    context "with HTML-characters" do
      let(:markdown) do
        "<>&"
      end

      it "sanitizes them" do
        should eq <<-EOS.strip_heredoc
          <p>&lt;&gt;&amp;</p>
        EOS
      end
    end

    context "with email address" do
      let(:markdown) do
        "test@example.com"
      end

      it "replaces with mailto link" do
        should eq <<-EOS.strip_heredoc
          <p><a href="mailto:test@example.com" class="autolink">test@example.com</a></p>
        EOS
      end
    end

    context "with headings" do
      let(:markdown) do
        <<-EOS.strip_heredoc
          # a
          ## a
          ### a
          ### a
        EOS
      end

      it "adds ID for ToC" do
        should eq <<-EOS.strip_heredoc

          <h1>
          <span id="a" class="fragment"></span><a href="#a"><i class="fa fa-link"></i></a>a</h1>

          <h2>
          <span id="a-1" class="fragment"></span><a href="#a-1"><i class="fa fa-link"></i></a>a</h2>

          <h3>
          <span id="a-2" class="fragment"></span><a href="#a-2"><i class="fa fa-link"></i></a>a</h3>

          <h3>
          <span id="a-3" class="fragment"></span><a href="#a-3"><i class="fa fa-link"></i></a>a</h3>
        EOS
      end
    end

    context "with code" do
      let(:markdown) do
        <<-EOS.strip_heredoc
          ```foo.rb
          puts 'hello world'
          ```
        EOS
      end

      it "returns detected codes" do
        expect(result[:codes]).to eq [
          {
            code: "puts 'hello world'\n",
            filename: "foo.rb",
            language: "ruby",
          },
        ]
      end
    end

    context "with code & filename" do
      let(:markdown) do
        <<-EOS.strip_heredoc
          ```example.rb
          1
          ```
        EOS
      end

      it "returns code-frame, code-lang, and highlighted pre element" do
        should eq <<-EOS.strip_heredoc
          <div class="code-frame" data-lang="ruby">
          <div class="code-lang"><span class="bold">example.rb</span></div>
          <div class="highlight"><pre>
          <span class="mi">1</span>
          </pre></div>
          </div>
        EOS
      end
    end

    context "with code & filename with .php" do
      let(:markdown) do
        <<-EOS.strip_heredoc
          ```example.php
          1
          ```
        EOS
      end

      it "returns PHP code-frame" do
        should eq <<-EOS.strip_heredoc
          <div class="code-frame" data-lang="php">
          <div class="code-lang"><span class="bold">example.php</span></div>
          <div class="highlight"><pre>
          <span class="mi">1</span>
          </pre></div>
          </div>
        EOS
      end
    end

    context "with malicious script in filename" do
      let(:markdown) do
        <<-EOS.strip_heredoc
          ```js:test<script>alert(1)</script>
          1
          ```
        EOS
      end

      it "sanitizes script element" do
        should eq <<-EOS.strip_heredoc
          <div class="code-frame" data-lang="js">
          <div class="code-lang"><span class="bold">test</span></div>
          <div class="highlight"><pre>
          <span class="mi">1</span>
          </pre></div>
          </div>
        EOS
      end
    end

    context "with code & no filename" do
      let(:markdown) do
        <<-EOS.strip_heredoc
          ```ruby
          1
          ```
        EOS
      end

      it "returns code-frame and highlighted pre element" do
        should eq <<-EOS.strip_heredoc
          <div class="code-frame" data-lang="ruby"><div class="highlight"><pre>
          <span class="mi">1</span>
          </pre></div></div>
        EOS
      end
    end

    context "with undefined but aliased language" do
      let(:markdown) do
        <<-EOS.strip_heredoc
          ```zsh
          true
          ```
        EOS
      end

      it "returns aliased language name" do
        expect(result[:codes]).to eq [
          {
            code: "true\n",
            filename: nil,
            language: "bash",
          },
        ]
      end
    end

    context "with code with leading and trailing newlines" do
      let(:markdown) do
        <<-EOS.strip_heredoc
          ```

          foo

          ```
        EOS
      end

      it "does not strip the newlines" do
        should eq <<-EOS.strip_heredoc
          <div class="code-frame" data-lang="text"><div class="highlight"><pre>

          foo

          </pre></div></div>
         EOS
      end
    end

    context "with script element" do
      let(:markdown) do
        <<-EOS.strip_heredoc
          <script>alert(1)</script>
        EOS
      end

      it "removes script element" do
        should eq "\n"
      end
    end

    context "with script context" do
      before do
        context[:script] = true
      end

      let(:markdown) do
        <<-EOS.strip_heredoc
          <p><script>alert(1)</script></p>
        EOS
      end

      it "allows script element" do
        should eq markdown
      end
    end

    context "with allowed attributes" do
      before do
        context[:script] = true
      end

      let(:markdown) do
        <<-EOS.strip_heredoc
          <p><script async data-a="b" type="text/javascript">alert(1)</script></p>
        EOS
      end

      it "allows data-attributes" do
        should eq markdown
      end
    end

    context "with iframe" do
      before do
        context[:script] = true
      end

      let(:markdown) do
        <<-EOS.strip_heredoc
          <iframe width="1" height="2" src="//example.com" frameborder="0" allowfullscreen></iframe>
        EOS
      end

      it "allows iframe with some attributes" do
        should eq markdown
      end
    end

    context "with mention" do
      let(:markdown) do
        "@alice"
      end

      it "replaces mention with link" do
        should include(<<-EOS.strip_heredoc.rstrip)
          <a href="/alice" class="user-mention js-hovercard" title="alice" data-hovercard-target-type="user" data-hovercard-target-name="alice">@alice</a>
        EOS
      end
    end

    context "with mention to short name user" do
      let(:markdown) do
        "@al"
      end

      it "replaces mention with link" do
        should include(<<-EOS.strip_heredoc.rstrip)
          <a href="/al" class="user-mention js-hovercard" title="al" data-hovercard-target-type="user" data-hovercard-target-name="al">@al</a>
        EOS
      end
    end

    context "with mentions in complex patterns" do
      let(:markdown) do
        <<-EOS.strip_heredoc
          @alice

          ```
            @bob
          ```

          @charlie/@dave
          @ell_en
          @fran-k
          @Isaac
          @justin
          @justin
          @mallory@github
          @#{'o' * 33}
          @o
          @o-
          @-o
          @o_
          @_o
        EOS
      end

      it "extracts mentions correctly" do
        expect(result[:mentioned_usernames]).to eq %w[
          alice
          dave
          ell_en
          fran-k
          Isaac
          justin
          mallory@github
          o_
          _o
        ]
      end
    end

    context "with mention-like filename on code block" do
      let(:markdown) do
        <<-EOS.strip_heredoc
          ```ruby:@alice
          1
          ```
        EOS
      end

      it "does not treat it as mention" do
        should include(<<-EOS.strip_heredoc.rstrip)
          <div class="code-frame" data-lang="ruby">
          <div class="code-lang"><span class="bold">@alice</span></div>
          <div class="highlight"><pre>
          <span class="mi">1</span>
          </pre></div>
          </div>
        EOS
      end
    end

    context "with mention in blockquote" do
      let(:markdown) do
        "> @alice"
      end

      it "does not replace mention with link" do
        should include(<<-EOS.strip_heredoc.rstrip)
          <blockquote>
          <p>@alice</p>
          </blockquote>
        EOS
      end
    end

    context "with mention to user whose name starts and ends with underscore" do
      let(:markdown) do
        "@_alice_"
      end

      it "does not emphasize the name" do
        should include(<<-EOS.strip_heredoc.rstrip)
          <a href="/_alice_" class="user-mention js-hovercard" title="_alice_" data-hovercard-target-type="user" data-hovercard-target-name="_alice_">@_alice_</a>
        EOS
      end
    end

    context "with allowed_usernames context" do
      before do
        context[:allowed_usernames] = ["alice"]
      end

      let(:markdown) do
        <<-EOS.strip_heredoc
          @alice
          @bob
        EOS
      end

      it "limits mentions to allowed usernames" do
        expect(result[:mentioned_usernames]).to eq ["alice"]
      end
    end

    context "with @all and allowed_usernames context" do
      before do
        context[:allowed_usernames] = ["alice", "bob"]
      end

      let(:markdown) do
        "@all"
      end

      it "links it and reports all allowed users as mentioned user names" do
        should include(<<-EOS.strip_heredoc.rstrip)
          <a href="/" class="user-mention" title="all">@all</a>
        EOS
        expect(result[:mentioned_usernames]).to eq context[:allowed_usernames]
      end
    end

    context "with @all and @alice" do
      before do
        context[:allowed_usernames] = ["alice", "bob"]
      end

      let(:markdown) do
        "@all @alice"
      end

      it "does not duplicate mentioned user names" do
        expect(result[:mentioned_usernames]).to eq context[:allowed_usernames]
      end
    end

    context "with @all and no allowed_usernames context" do
      let(:markdown) do
        "@all"
      end

      it "does not repond to @all" do
        should eq "<p>@all</p>\n"
        expect(result[:mentioned_usernames]).to eq []
      end
    end

    context "with group mention without group_memberion_url_generator" do
      let(:markdown) do
        "@alice/bob"
      end

      it "does not replace it" do
        is_expected.to eq <<-EOS.strip_heredoc
          <p>@alice/bob</p>
        EOS
      end
    end

    context "with group mention" do
      let(:context) do
        super().merge(group_mention_url_generator: lambda do |group|
          "https://#{group[:team_url_name]}.example.com/groups/#{group[:group_url_name]}"
        end)
      end

      let(:markdown) do
        "@alice/bob"
      end

      it "replaces it with preferred link and updates :mentioned_groups" do
        is_expected.to eq <<-EOS.strip_heredoc
          <p><a href="https://alice.example.com/groups/bob" rel="nofollow noopener" target="_blank">@alice/bob</a></p>
        EOS
        expect(result[:mentioned_groups]).to eq [{
          group_url_name: "bob",
          team_url_name: "alice",
        }]
      end
    end

    context "with normal link" do
      let(:markdown) do
        "[](/example)"
      end

      it "creates link for that" do
        should eq <<-EOS.strip_heredoc
          <p><a href="/example"></a></p>
        EOS
      end
    end

    context "with anchor link" do
      let(:markdown) do
        "[](#example)"
      end

      it "creates link for that" do
        should eq <<-EOS.strip_heredoc
          <p><a href="#example"></a></p>
        EOS
      end
    end

    context "with raw URL" do
      let(:markdown) do
        "http://example.com/search?q=日本語"
      end

      it "creates link for that with .autolink class" do
        should eq(
          '<p><a href="http://example.com/search?q=%E6%97%A5%E6%9C%AC%E8%AA%9E" class="autolink">' \
          "http://example.com/search?q=日本語</a></p>\n"
        )
      end
    end

    context "with javascript: link" do
      let(:markdown) do
        "[](javascript:alert(1))"
      end

      it "removes that link by creating empty a element" do
        should eq <<-EOS.strip_heredoc
          <p><a></a></p>
        EOS
      end
    end

    context "with emoji" do
      let(:markdown) do
        ":+1:"
      end

      it "replaces it with img element" do
        should include("img")
      end
    end

    context "with emoji in pre or code element" do
      let(:markdown) do
        <<-EOS.strip_heredoc
          ```
          :+1:
          ```
        EOS
      end

      it "does not replace it" do
        should_not include("img")
      end
    end

    context "with image notation" do
      let(:markdown) do
        "![a](http://example.com/b.png)"
      end

      it "wraps it in a element" do
        should eq '<p><a href="http://example.com/b.png" target="_blank">' +
                  %(<img src="http://example.com/b.png" alt="a"></a></p>\n)
      end
    end

    context "with colon-only label" do
      let(:markdown) do
        <<-EOS.strip_heredoc
          ```:
          1
          ```
        EOS
      end

      it "does not replace it" do
        expect(result[:codes]).to eq [
          {
            code: "1\n",
            filename: nil,
            language: nil,
          },
        ]
      end
    end

    context "with font element with color attribute" do
      let(:markdown) do
        %[<font color="red">test</font>]
      end

      it "allows font element with color attribute" do
        should eq <<-EOS.strip_heredoc
          <p>#{markdown}</p>
        EOS
      end
    end

    context "with task list" do
      let(:markdown) do
        <<-EOS.strip_heredoc
          - [ ] a
          - [x] b
        EOS
      end

      it "inserts checkbox" do
        should eq <<-EOS.strip_heredoc
          <ul>
          <li class="task-list-item">
          <input type="checkbox" class="task-list-item-checkbox" disabled>a</li>
          <li class="task-list-item">
          <input type="checkbox" class="task-list-item-checkbox" checked disabled>b</li>
          </ul>
        EOS
      end
    end

    context "with nested task list" do
      let(:markdown) do
        <<-EOS.strip_heredoc
          - [ ] a
           - [ ] b
        EOS
      end

      it "inserts checkbox" do
        should eq <<-EOS.strip_heredoc
          <ul>
          <li class="task-list-item">
          <input type="checkbox" class="task-list-item-checkbox" disabled>a

          <ul>
          <li class="task-list-item">
          <input type="checkbox" class="task-list-item-checkbox" disabled>b</li>
          </ul>
          </li>
          </ul>
        EOS
      end
    end

    context "with task list in code block" do
      let(:markdown) do
        <<-EOS.strip_heredoc
          ```
          - [ ] a
          - [x] b
          ```
        EOS
      end

      it "does not replace checkbox" do
        should eq <<-EOS.strip_heredoc
          <div class="code-frame" data-lang="text"><div class="highlight"><pre>
          - [ ] a
          - [x] b
          </pre></div></div>
        EOS
      end
    end

    context "with empty line between task list" do
      let(:markdown) do
        <<-EOS.strip_heredoc
          - [ ] a

          - [x] b
        EOS
      end

      it "inserts checkbox" do
        should eq <<-EOS.strip_heredoc
          <ul>
          <li class="task-list-item"><p><input type="checkbox" class="task-list-item-checkbox" disabled>a</p></li>
          <li class="task-list-item"><p><input type="checkbox" class="task-list-item-checkbox" checked disabled>b</p></li>
          </ul>
        EOS
      end
    end

    context "with empty list" do
      let(:markdown) do
        "- \n"
      end

      it "inserts checkbox" do
        should eq <<-EOS.strip_heredoc
          <ul>
          <li>
          </ul>
        EOS
      end
    end

    context "with text-aligned table" do
      let(:markdown) do
        <<-EOS.strip_heredoc
          | a  | b  | c   |
          |:---|---:|:---:|
          | a  | b  | c   |
        EOS
      end

      it "creates table element with text-align style" do
        should eq <<-EOS.strip_heredoc
          <table>
          <thead>
          <tr>
          <th style="text-align: left">a</th>
          <th style="text-align: right">b</th>
          <th style="text-align: center">c</th>
          </tr>
          </thead>
          <tbody>
          <tr>
          <td style="text-align: left">a</td>
          <td style="text-align: right">b</td>
          <td style="text-align: center">c</td>
          </tr>
          </tbody>
          </table>
        EOS
      end
    end

    context "with footenotes syntax" do
      let(:markdown) do
        <<-EOS.strip_heredoc
          [^1]
          [^1]: test
        EOS
      end

      it "generates footnotes elements" do
        should eq <<-EOS.strip_heredoc
          <p><sup id="fnref1"><a href="#fn1" rel="footnote" title="test">1</a></sup></p>

          <div class="footnotes">
          <hr>
          <ol>

          <li id="fn1">
          <p>test <a href="#fnref1">↩</a></p>
          </li>

          </ol>
          </div>
        EOS
      end
    end

    context "with manually written link inside of <sup> tag" do
      let(:markdown) do
        <<-EOS.strip_heredoc
          <sup>[Example](http://example.com/)</sup>
        EOS
      end

      it "does not confuse the structure with automatically generated footnote reference" do
        should eq <<-EOS.strip_heredoc
          <p><sup><a href="http://example.com/">Example</a></sup></p>
        EOS
      end
    end

    context "with manually written <a> tag with strange href inside of <sup> tag" do
      let(:markdown) do
        <<-EOS.strip_heredoc
          <sup><a href="#foo.1">Link</a></sup>
        EOS
      end

      it "does not confuse the structure with automatically generated footnote reference" do
        should eq <<-EOS.strip_heredoc
          <p><sup><a href="#foo.1">Link</a></sup></p>
        EOS
      end
    end

    context "with markdown: { footnotes: false } context" do
      before do
        context[:markdown] = { footnotes: false }
      end

      let(:markdown) do
        <<-EOS.strip_heredoc
          [^1]
          [^1]: test
        EOS
      end

      it "does not generate footnote elements" do
        should eq <<-EOS.strip_heredoc
          <p><a href="test">^1</a></p>
        EOS
      end
    end

    context "with data-attributes" do
      let(:markdown) do
        <<-EOS.strip_heredoc
          <div data-a="b"></div>
        EOS
      end

      it "sanitizes data-attributes" do
        should eq <<-EOS.strip_heredoc
          <div></div>
        EOS
      end
    end

    context "with data-attributes and :script option" do
      before do
        context[:script] = true
      end

      let(:markdown) do
        <<-EOS.strip_heredoc
          <div data-a="b"></div>
        EOS
      end

      it "does not sanitize data-attributes" do
        should eq <<-EOS.strip_heredoc
          <div data-a="b"></div>
        EOS
      end
    end

    context "with emoji_names and emoji_url_generator context" do
      before do
        context[:emoji_names] = %w(foo o)

        context[:emoji_url_generator] = proc do |emoji_name|
          "https://example.com/foo.png" if emoji_name == "foo"
        end
      end

      let(:markdown) do
        <<-EOS.strip_heredoc
          :foo: :o: :x:
        EOS
      end

      it "replaces only the specified emoji names with img elements with custom URL" do
        should include(
          '<img class="emoji" title=":foo:" alt=":foo:" src="https://example.com/foo.png"',
          '<img class="emoji" title=":o:" alt=":o:" src="/images/emoji/unicode/2b55.png"'
        )

        should_not include(
          '<img class="emoji" title=":x:" alt=":x:"'
        )
      end
    end

    context "with internal URL" do
      let(:markdown) do
        "http://qiita.com/?a=b"
      end

      let(:context) do
        { hostname: "qiita.com" }
      end

      it "creates link which does not have rel='nofollow noopener' and target='_blank'" do
        should eq(
          '<p><a href="http://qiita.com/?a=b" class="autolink">' \
          "http://qiita.com/?a=b</a></p>\n"
        )
      end
    end

    context "with external URL" do
      let(:markdown) do
        "http://external.com/?a=b"
      end

      let(:context) do
        { hostname: "qiita.com" }
      end

      it "creates link which has rel='nofollow noopener' and target='_blank'" do
        should eq(
          '<p><a href="http://external.com/?a=b" class="autolink" rel="nofollow noopener" target="_blank">' \
          "http://external.com/?a=b</a></p>\n"
        )
      end
    end

    context "with internal anchor tag" do
      let(:markdown) do
        '<a href="http://qiita.com/?a=b">foobar</a>'
      end

      let(:context) do
        { hostname: "qiita.com" }
      end

      it "creates link which does not have rel='nofollow noopener' and target='_blank'" do
        should eq(
          "<p><a href=\"http://qiita.com/?a=b\">foobar</a></p>\n"
        )
      end
    end

    context "with external anchor tag" do
      let(:markdown) do
        '<a href="http://external.com/?a=b">foobar</a>'
      end

      let(:context) do
        { hostname: "qiita.com" }
      end

      it "creates link which has rel='nofollow noopener' and target='_blank'" do
        should eq(
          "<p><a href=\"http://external.com/?a=b\" rel=\"nofollow noopener\" target=\"_blank\">foobar</a></p>\n"
        )
      end
    end

    context "with external URL which ends with the hostname parameter" do
      let(:markdown) do
        "http://qqqqqqiita.com/?a=b"
      end

      let(:context) do
        { hostname: "qiita.com" }
      end

      it "creates link which has rel='nofollow noopener' and target='_blank'" do
        should eq(
          '<p><a href="http://qqqqqqiita.com/?a=b" class="autolink" rel="nofollow noopener" target="_blank">' \
          "http://qqqqqqiita.com/?a=b</a></p>\n"
        )
      end
    end

    context "with external anchor tag which ends with the hostname parameter" do
      let(:markdown) do
        '<a href="http://qqqqqqiita.com/?a=b">foobar</a>'
      end

      let(:context) do
        { hostname: "qiita.com" }
      end

      it "creates link which has rel='nofollow noopener' and target='_blank'" do
        should eq(
          "<p><a href=\"http://qqqqqqiita.com/?a=b\" rel=\"nofollow noopener\" target=\"_blank\">foobar</a></p>\n"
        )
      end
    end

    context "with sub-domain URL of hostname parameter" do
      let(:markdown) do
        "http://sub.qiita.com/?a=b"
      end

      let(:context) do
        { hostname: "qiita.com" }
      end

      it "creates link which has rel='nofollow noopener' and target='_blank'" do
        should eq(
          '<p><a href="http://sub.qiita.com/?a=b" class="autolink" rel="nofollow noopener" target="_blank">' \
          "http://sub.qiita.com/?a=b</a></p>\n"
        )
      end
    end

    context "with external anchor tag which has rel attribute" do
      let(:markdown) do
        '<a href="http://external.com/?a=b" rel="url">foobar</a>'
      end

      let(:context) do
        { hostname: "qiita.com" }
      end

      it "creates link which has rel='nofollow noopener' and target='_blank', and rel value is overwritten" do
        should eq(
          "<p><a href=\"http://external.com/?a=b\" rel=\"nofollow noopener\" target=\"_blank\">foobar</a></p>\n"
        )
      end
    end
  end
end
