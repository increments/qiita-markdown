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

    shared_examples_for "basic markdown syntax" do
      context "with valid condition" do
        let(:markdown) do
          <<-MARKDOWN.strip_heredoc
            example
          MARKDOWN
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
          should eq <<-HTML.strip_heredoc
            <p>&lt;&gt;&amp;</p>
          HTML
        end
      end

      context "with email address" do
        let(:markdown) do
          "test@example.com"
        end

        it "replaces with mailto link" do
          should eq <<-HTML.strip_heredoc
            <p><a href="mailto:test@example.com" class="autolink">test@example.com</a></p>
          HTML
        end
      end

      context "with headings" do
        let(:markdown) do
          <<-MARKDOWN.strip_heredoc
            # a
            ## a
            ### a
            ### a
          MARKDOWN
        end

        it "adds ID for ToC" do
          should eq <<-HTML.strip_heredoc

            <h1>
            <span id="a" class="fragment"></span><a href="#a"><i class="fa fa-link"></i></a>a</h1>

            <h2>
            <span id="a-1" class="fragment"></span><a href="#a-1"><i class="fa fa-link"></i></a>a</h2>

            <h3>
            <span id="a-2" class="fragment"></span><a href="#a-2"><i class="fa fa-link"></i></a>a</h3>

            <h3>
            <span id="a-3" class="fragment"></span><a href="#a-3"><i class="fa fa-link"></i></a>a</h3>
          HTML
        end
      end

      context "with heading whose title includes special HTML characters" do
        let(:markdown) do
          <<-MARKDOWN.strip_heredoc
            # <b>R&amp;B</b>
          MARKDOWN
        end

        it "generates fragment identifier by sanitizing the special characters in the title" do
          should eq <<-HTML.strip_heredoc

            <h1>
            <span id="rb" class="fragment"></span><a href="#rb"><i class="fa fa-link"></i></a><b>R&amp;B</b>
            </h1>
          HTML
        end
      end

      context "with manually inputted heading HTML tags without id attribute" do
        let(:markdown) do
          <<-MARKDOWN.strip_heredoc
            <h1>foo</h1>
          MARKDOWN
        end

        it "does nothing" do
          should eq <<-HTML.strip_heredoc
            <h1>foo</h1>
          HTML
        end
      end

      context "with code" do
        let(:markdown) do
          <<-MARKDOWN.strip_heredoc
            ```foo.rb
            puts 'hello world'
            ```
          MARKDOWN
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
          <<-MARKDOWN.strip_heredoc
            ```example.rb
            1
            ```
          MARKDOWN
        end

        it "returns code-frame, code-lang, and highlighted pre element" do
          should eq <<-HTML.strip_heredoc
            <div class="code-frame" data-lang="ruby">
            <div class="code-lang"><span class="bold">example.rb</span></div>
            <div class="highlight"><pre><span></span><span class="mi">1</span>
            </pre></div>
            </div>
          HTML
        end
      end

      context "with code & filename with .php" do
        let(:markdown) do
          <<-MARKDOWN.strip_heredoc
            ```example.php
            1
            ```
          MARKDOWN
        end

        it "returns PHP code-frame" do
          should eq <<-HTML.strip_heredoc
            <div class="code-frame" data-lang="php">
            <div class="code-lang"><span class="bold">example.php</span></div>
            <div class="highlight"><pre><span></span><span class="mi">1</span>
            </pre></div>
            </div>
          HTML
        end
      end

      context "with code & no filename" do
        let(:markdown) do
          <<-MARKDOWN.strip_heredoc
            ```ruby
            1
            ```
          MARKDOWN
        end

        it "returns code-frame and highlighted pre element" do
          should eq <<-HTML.strip_heredoc
            <div class="code-frame" data-lang="ruby"><div class="highlight"><pre><span></span><span class="mi">1</span>
            </pre></div></div>
          HTML
        end
      end

      context "with undefined but aliased language" do
        let(:markdown) do
          <<-MARKDOWN.strip_heredoc
            ```zsh
            true
            ```
          MARKDOWN
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
          <<-MARKDOWN.strip_heredoc
            ```

            foo

            ```
          MARKDOWN
        end

        it "does not strip the newlines" do
          should eq <<-HTML.strip_heredoc
            <div class="code-frame" data-lang="text"><div class="highlight"><pre><span></span>
            foo

            </pre></div></div>
           HTML
        end
      end

      context "with mention" do
        let(:markdown) do
          "@alice"
        end

        it "replaces mention with link" do
          should include(<<-HTML.strip_heredoc.rstrip)
            <a href="/alice" class="user-mention js-hovercard" title="alice" data-hovercard-target-type="user" data-hovercard-target-name="alice">@alice</a>
          HTML
        end
      end

      context "with mention to short name user" do
        let(:markdown) do
          "@al"
        end

        it "replaces mention with link" do
          should include(<<-HTML.strip_heredoc.rstrip)
            <a href="/al" class="user-mention js-hovercard" title="al" data-hovercard-target-type="user" data-hovercard-target-name="al">@al</a>
          HTML
        end
      end

      context "with mentions in complex patterns" do
        let(:markdown) do
          <<-MARKDOWN.strip_heredoc
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
          MARKDOWN
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
          <<-MARKDOWN.strip_heredoc
            ```ruby:@alice
            1
            ```
          MARKDOWN
        end

        it "does not treat it as mention" do
          should include(<<-HTML.strip_heredoc.rstrip)
            <div class="code-frame" data-lang="ruby">
            <div class="code-lang"><span class="bold">@alice</span></div>
            <div class="highlight"><pre><span></span><span class="mi">1</span>
            </pre></div>
            </div>
          HTML
        end
      end

      context "with mention in blockquote" do
        let(:markdown) do
          "> @alice"
        end

        it "does not replace mention with link" do
          should include(<<-HTML.strip_heredoc.rstrip)
            <blockquote>
            <p>@alice</p>
            </blockquote>
          HTML
        end
      end

      context "with mention to user whose name starts and ends with underscore" do
        let(:markdown) do
          "@_alice_"
        end

        it "does not emphasize the name" do
          should include(<<-HTML.strip_heredoc.rstrip)
            <a href="/_alice_" class="user-mention js-hovercard" title="_alice_" data-hovercard-target-type="user" data-hovercard-target-name="_alice_">@_alice_</a>
          HTML
        end
      end

      context "with allowed_usernames context" do
        before do
          context[:allowed_usernames] = ["alice"]
        end

        let(:markdown) do
          <<-MARKDOWN.strip_heredoc
            @alice
            @bob
          MARKDOWN
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
          should include(<<-HTML.strip_heredoc.rstrip)
            <a href="/" class="user-mention" title="all">@all</a>
          HTML
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
          is_expected.to eq <<-HTML.strip_heredoc
            <p>@alice/bob</p>
          HTML
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
          is_expected.to eq <<-HTML.strip_heredoc
            <p><a href="https://alice.example.com/groups/bob" rel="nofollow noopener" target="_blank">@alice/bob</a></p>
          HTML
          expect(result[:mentioned_groups]).to eq [{
            group_url_name: "bob",
            team_url_name: "alice",
          }]
        end
      end

      context "with group mention following another text" do
        let(:context) do
          super().merge(group_mention_url_generator: lambda do |group|
            "https://#{group[:team_url_name]}.example.com/groups/#{group[:group_url_name]}"
          end)
        end

        let(:markdown) do
          "FYI @alice/bob"
        end

        it "preserves space after preceding text" do
          is_expected.to start_with("<p>FYI <a ")
        end
      end

      context "with normal link" do
        let(:markdown) do
          "[](/example)"
        end

        it "creates link for that" do
          should eq <<-HTML.strip_heredoc
            <p><a href="/example"></a></p>
          HTML
        end
      end

      context "with anchor link" do
        let(:markdown) do
          "[](#example)"
        end

        it "creates link for that" do
          should eq <<-HTML.strip_heredoc
            <p><a href="#example"></a></p>
          HTML
        end
      end

      context "with link with title" do
        let(:markdown) do
          '[](/example "Title")'
        end

        it "creates link for that with the title" do
          should eq <<-HTML.strip_heredoc
            <p><a href="/example" title="Title"></a></p>
          HTML
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
          should eq <<-HTML.strip_heredoc
            <p><a></a></p>
          HTML
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
          <<-MARKDOWN.strip_heredoc
            ```
            :+1:
            ```
          MARKDOWN
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
          should eq %(<p><a href="http://example.com/b.png" target="_blank">) +
                    %(<img src="http://example.com/b.png" alt="a"></a></p>\n)
        end
      end

      context "with image notation with title" do
        let(:markdown) do
          '![a](http://example.com/b.png "Title")'
        end

        it "generates <img> tag with the title" do
          should eq %(<p><a href="http://example.com/b.png" target="_blank">) +
                    %(<img src="http://example.com/b.png" alt="a" title="Title"></a></p>\n)
        end
      end

      context "with <img> tag with width and height attribute (for Retina image)" do
        let(:markdown) do
          '<img width="80" height="48" alt="a" src="http://example.com/b.png">'
        end

        it "wraps it in a element while keeping the width attribute" do
          should eq %(<p><a href="http://example.com/b.png" target="_blank">) +
                    %(<img width="80" height="48" alt="a" src="http://example.com/b.png"></a></p>\n)
        end
      end

      context "with colon-only label" do
        let(:markdown) do
          <<-MARKDOWN.strip_heredoc
            ```:
            1
            ```
          MARKDOWN
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
          should eq <<-HTML.strip_heredoc
            <p>#{markdown}</p>
          HTML
        end
      end

      context "with task list" do
        let(:markdown) do
          <<-MARKDOWN.strip_heredoc
            - [ ] a
            - [x] b
          MARKDOWN
        end

        it "inserts checkbox" do
          should eq <<-HTML.strip_heredoc
            <ul>
            <li class="task-list-item">
            <input type="checkbox" class="task-list-item-checkbox" disabled>a</li>
            <li class="task-list-item">
            <input type="checkbox" class="task-list-item-checkbox" checked disabled>b</li>
            </ul>
          HTML
        end
      end

      context "with nested task list" do
        let(:markdown) do
          <<-MARKDOWN.strip_heredoc
            - [ ] a
             - [ ] b
          MARKDOWN
        end

        it "inserts checkbox" do
          should eq <<-HTML.strip_heredoc
            <ul>
            <li class="task-list-item">
            <input type="checkbox" class="task-list-item-checkbox" disabled>a

            <ul>
            <li class="task-list-item">
            <input type="checkbox" class="task-list-item-checkbox" disabled>b</li>
            </ul>
            </li>
            </ul>
          HTML
        end
      end

      context "with task list in code block" do
        let(:markdown) do
          <<-MARKDOWN.strip_heredoc
            ```
            - [ ] a
            - [x] b
            ```
          MARKDOWN
        end

        it "does not replace checkbox" do
          should eq <<-HTML.strip_heredoc
            <div class="code-frame" data-lang="text"><div class="highlight"><pre><span></span>- [ ] a
            - [x] b
            </pre></div></div>
          HTML
        end
      end

      context "with empty line between task list" do
        let(:markdown) do
          <<-MARKDOWN.strip_heredoc
            - [ ] a

            - [x] b
          MARKDOWN
        end

        it "inserts checkbox" do
          should eq <<-HTML.strip_heredoc
            <ul>
            <li class="task-list-item"><p><input type="checkbox" class="task-list-item-checkbox" disabled>a</p></li>
            <li class="task-list-item"><p><input type="checkbox" class="task-list-item-checkbox" checked disabled>b</p></li>
            </ul>
          HTML
        end
      end

      context "with empty list" do
        let(:markdown) do
          "- \n"
        end

        it "inserts checkbox" do
          should eq <<-HTML.strip_heredoc
            <ul>
            <li>
            </ul>
          HTML
        end
      end

      context "with text-aligned table" do
        let(:markdown) do
          <<-MARKDOWN.strip_heredoc
            | a  | b  | c   |
            |:---|---:|:---:|
            | a  | b  | c   |
          MARKDOWN
        end

        it "creates table element with text-align style" do
          should eq <<-HTML.strip_heredoc
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
          HTML
        end
      end

      context "with footenotes syntax" do
        let(:markdown) do
          <<-MARKDOWN.strip_heredoc
            [^1]
            [^1]: test
          MARKDOWN
        end

        it "generates footnotes elements" do
          should eq <<-HTML.strip_heredoc
            <p><sup id="fnref1"><a href="#fn1" title="test">1</a></sup></p>

            <div class="footnotes">
            <hr>
            <ol>

            <li id="fn1">
            <p>test <a href="#fnref1">↩</a></p>
            </li>

            </ol>
            </div>
          HTML
        end
      end

      context "with footenotes syntax with code block" do
        let(:markdown) do
          <<-MARKDOWN.strip_heredoc
            ```
            [^1]
            [^1]: test
            ```
          MARKDOWN
        end

        it "generates only code blocks without footnotes" do
          should eq <<-HTML.strip_heredoc
            <div class="code-frame" data-lang="text"><div class="highlight"><pre><span></span>[^1]
            [^1]: test
            </pre></div></div>
          HTML
        end
      end

      context "with manually written link inside of <sup> tag" do
        let(:markdown) do
          <<-MARKDOWN.strip_heredoc
            <sup>[Example](http://example.com/)</sup>
          MARKDOWN
        end

        it "does not confuse the structure with automatically generated footnote reference" do
          should eq <<-HTML.strip_heredoc
            <p><sup><a href="http://example.com/">Example</a></sup></p>
          HTML
        end
      end

      context "with manually written <a> tag with strange href inside of <sup> tag" do
        let(:markdown) do
          <<-MARKDOWN.strip_heredoc
            <sup><a href="#foo.1">Link</a></sup>
          MARKDOWN
        end

        it "does not confuse the structure with automatically generated footnote reference" do
          should eq <<-HTML.strip_heredoc
            <p><sup><a href="#foo.1">Link</a></sup></p>
          HTML
        end
      end

      context "with markdown: { footnotes: false } context" do
        before do
          context[:markdown] = { footnotes: false }
        end

        let(:markdown) do
          <<-MARKDOWN.strip_heredoc
            [^1]
            [^1]: test
          MARKDOWN
        end

        it "does not generate footnote elements" do
          should eq <<-HTML.strip_heredoc
            <p><a href="test">^1</a></p>
          HTML
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
          <<-MARKDOWN.strip_heredoc
            :foo: :o: :x:
          MARKDOWN
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

      context "with blockquote syntax" do
        let(:markdown) do
          "> foo"
        end

        it "does not confuse it with HTML tag angle brackets" do
          should eq "<blockquote>\n<p>foo</p>\n</blockquote>\n"
        end
      end

      context "with inline code containing hexadecimal color only" do
        let(:markdown) do
          "`#FF0000`"
        end

        it "returns code element with its color" do
          should eq "<p><code>#FF0000<span class=\"inline-code-color\" style=\"background-color: #FF0000;\"></span></code></p>\n"
        end

        context "with class name of inline code color parameter" do
          let(:context) do
            super().merge(inline_code_color_class_name: "qiita-inline-code-color")
          end

          it "returns returns code element with its color whose class name is parameter value" do
            should eq "<p><code>#FF0000<span class=\"qiita-inline-code-color\" style=\"background-color: #FF0000;\"></span></code></p>\n"
          end
        end
      end

      context "with inline code containing rgb color only" do
        let(:markdown) do
          "`rgb(255, 0, 0)`"
        end

        it "returns code element with its color" do
          should eq "<p><code>rgb(255, 0, 0)<span class=\"inline-code-color\" style=\"background-color: rgb(255, 0, 0);\"></span></code></p>\n"
        end

        context "with class name of inline code color parameter" do
          let(:context) do
            super().merge(inline_code_color_class_name: "qiita-inline-code-color")
          end

          it "returns returns code element with its color whose class name is parameter value" do
            should eq "<p><code>rgb(255, 0, 0)<span class=\"qiita-inline-code-color\" style=\"background-color: rgb(255, 0, 0);\"></span></code></p>\n"
          end
        end
      end

      context "with inline code containing hsl color only" do
        let(:markdown) do
          "`hsl(0, 100%, 50%)`"
        end

        it "returns code element with its color" do
          should eq "<p><code>hsl(0, 100%, 50%)<span class=\"inline-code-color\" style=\"background-color: hsl(0, 100%, 50%);\"></span></code></p>\n"
        end

        context "with class name of inline code color parameter" do
          let(:context) do
            super().merge(inline_code_color_class_name: "qiita-inline-code-color")
          end

          it "returns returns code element with its color whose class name is parameter value" do
            should eq "<p><code>hsl(0, 100%, 50%)<span class=\"qiita-inline-code-color\" style=\"background-color: hsl(0, 100%, 50%);\"></span></code></p>\n"
          end
        end
      end

      context "with details tag" do
        let(:markdown) do
          <<-MARKDOWN.strip_heredoc
            <details><summary>Folding sample</summary><div>

            ```rb
            puts "Hello, World"
            ```
            </div></details>
          MARKDOWN
        end

        it "returns HTML output parsed as markdown" do
          expect(subject).to eq <<-HTML.strip_heredoc
            <p><details><summary>Folding sample</summary><div>

            <div class="code-frame" data-lang="rb"><div class="highlight"><pre><span></span><span class="nb">puts</span> <span class="s2">"Hello, World"</span>
            </pre></div></div>

            <p></p>
            </div></details></p>
          HTML
        end
      end
    end

    shared_examples_for "script element" do |allowed:|
      context "with script element" do
        let(:markdown) do
          <<-MARKDOWN.strip_heredoc
            <script>alert(1)</script>
          MARKDOWN
        end

        if allowed
          it "allows script element" do
            should eq markdown
          end

          context "and allowed attributes" do
            let(:markdown) do
              <<-MARKDOWN.strip_heredoc
                <p><script async data-a="b" type="text/javascript">alert(1)</script></p>
              MARKDOWN
            end

            it "allows data-attributes" do
              should eq markdown
            end
          end
        else
          it "removes script element" do
            should eq "\n"
          end
        end
      end
    end

    shared_examples_for "malicious script in filename" do |allowed:|
      context "with malicious script in filename" do
        let(:markdown) do
          <<-MARKDOWN.strip_heredoc
            ```js:test<script>alert(1)</script>
            1
            ```
          MARKDOWN
        end

        if allowed
          it "does not sanitize script element" do
            should eq <<-HTML.strip_heredoc
              <div class="code-frame" data-lang="js">
              <div class="code-lang"><span class="bold">test<script>alert(1)</script></span></div>
              <div class="highlight"><pre><span></span><span class="mi">1</span>
              </pre></div>
              </div>
            HTML
          end
        else
          it "sanitizes script element" do
            should eq <<-HTML.strip_heredoc
              <div class="code-frame" data-lang="js">
              <div class="code-lang"><span class="bold">test</span></div>
              <div class="highlight"><pre><span></span><span class="mi">1</span>
              </pre></div>
              </div>
            HTML
          end
        end
      end
    end

    shared_examples_for "iframe element" do |allowed:|
      shared_examples "iframe element example" do
        let(:markdown) do
          <<-MARKDOWN.strip_heredoc
            <iframe width="1" height="2" src="#{url}" frameborder="0" allowfullscreen></iframe>
          MARKDOWN
        end
        let(:url) { "#{scheme}//example.com" }

        if allowed
          it "allows iframe with some attributes" do
            should eq markdown
          end
        else
          it "sanitizes iframe element" do
            should eq "\n"
          end
        end
      end

      context "with iframe" do
        context "with scheme" do
          let(:scheme) { "https:" }

          include_examples "iframe element example"
        end

        context "without scheme" do
          let(:scheme) { "" }

          include_examples "iframe element example"
        end
      end
    end

    shared_examples_for "input element" do |allowed:|
      context "with input" do
        let(:markdown) do
          <<-MARKDOWN.strip_heredoc
            <input type="checkbox"> foo
          MARKDOWN
        end

        if allowed
          it "allows input with some attributes" do
            should eq "<p><input type=\"checkbox\"> foo</p>\n"
          end
        else
          it "sanitizes input element" do
            should eq "<p> foo</p>\n"
          end
        end
      end
    end

    shared_examples_for "data-attributes" do |allowed:|
      context "with data-attributes for general tags" do
        let(:markdown) do
          <<-MARKDOWN.strip_heredoc
            <div data-a="b"></div>
          MARKDOWN
        end

        if allowed
          it "does not sanitize data-attributes" do
            should eq <<-HTML.strip_heredoc
              <div data-a="b"></div>
            HTML
          end
        else
          it "sanitizes data-attributes" do
            should eq <<-HTML.strip_heredoc
              <div></div>
            HTML
          end
        end
      end

      context "with data-attributes for <blockquote> tag" do
        let(:markdown) do
          <<-MARKDOWN.strip_heredoc
            <blockquote data-theme="a" data-malicious="b"></blockquote>
          MARKDOWN
        end

        if allowed
          it "does not sanitize data-attributes" do
            should eq <<-HTML.strip_heredoc
              <blockquote data-theme="a" data-malicious="b"></blockquote>
            HTML
          end
        else
          it "sanitizes data-attributes except the attributes used by tweet" do
            should eq <<-HTML.strip_heredoc
              <blockquote data-theme="a"></blockquote>
            HTML
          end
        end
      end

      context "with data-attributes for <p> tag" do
        let(:markdown) do
          <<-MARKDOWN.strip_heredoc
            <p data-slug-hash="a" data-malicious="b"></p>
          MARKDOWN
        end

        if allowed
          it "does not sanitize data-attributes" do
            should eq <<-HTML.strip_heredoc
              <p data-slug-hash="a" data-malicious="b"></p>
            HTML
          end
        else
          it "sanitizes data-attributes except the attributes used by codepen" do
            should eq <<-HTML.strip_heredoc
              <p data-slug-hash="a"></p>
            HTML
          end
        end
      end
    end

    shared_examples_for "class attribute" do |allowed:|
      context "with class attribute for general tags" do
        let(:markdown) do
          '<i class="fa fa-user"></i>user'
        end

        if allowed
          it "does not sanitize the attribute" do
            should eq "<p><i class=\"fa fa-user\"></i>user</p>\n"
          end
        else
          it "sanitizes the attribute" do
            should eq "<p><i></i>user</p>\n"
          end
        end
      end

      context "with class attribute for <a> tag" do
        let(:markdown) do
          <<-MARKDOWN.strip_heredoc
            <a href="foo" class="malicious-class">foo</a>
            http://qiita.com/
          MARKDOWN
        end

        if allowed
          it "does not sanitize the classes" do
            should eq <<-HTML.strip_heredoc
              <p><a href="foo" class="malicious-class">foo</a><br>
              <a href="http://qiita.com/" class="autolink" rel="nofollow noopener" target="_blank">http://qiita.com/</a></p>
            HTML
          end
        else
          it "sanitizes classes except `autolink`" do
            should eq <<-HTML.strip_heredoc
              <p><a href="foo" class="">foo</a><br>
              <a href="http://qiita.com/" class="autolink" rel="nofollow noopener" target="_blank">http://qiita.com/</a></p>
            HTML
          end
        end
      end

      context "with class attribute for <blockquote> tag" do
        let(:markdown) do
          <<-MARKDOWN.strip_heredoc
            <blockquote class="twitter-tweet malicious-class">foo</blockquote>
          MARKDOWN
        end

        if allowed
          it "does not sanitize the classes" do
            should eq <<-HTML.strip_heredoc
              <blockquote class="twitter-tweet malicious-class">foo</blockquote>
            HTML
          end
        else
          it "sanitizes classes except `twitter-tweet`" do
            should eq <<-HTML.strip_heredoc
              <blockquote class="twitter-tweet">foo</blockquote>
            HTML
          end
        end
      end

      context "with class attribute for <div> tag" do
        let(:markdown) do
          <<-MARKDOWN.strip_heredoc
            <div class="footnotes malicious-class">foo</div>
          MARKDOWN
        end

        if allowed
          it "does not sanitize the classes" do
            should eq <<-HTML.strip_heredoc
              <div class="footnotes malicious-class">foo</div>
            HTML
          end
        else
          it "sanitizes classes except `footnotes`" do
            should eq <<-HTML.strip_heredoc
              <div class="footnotes">foo</div>
            HTML
          end
        end
      end

      context "with class attribute for <p> tag" do
        let(:markdown) do
          <<-MARKDOWN.strip_heredoc
            <p class="codepen malicious-class">foo</p>
          MARKDOWN
        end

        if allowed
          it "does not sanitize the classes" do
            should eq <<-HTML.strip_heredoc
              <p class="codepen malicious-class">foo</p>
            HTML
          end
        else
          it "sanitizes classes except `codepen`" do
            should eq <<-HTML.strip_heredoc
              <p class="codepen">foo</p>
            HTML
          end
        end
      end
    end

    shared_examples_for "background-color" do |allowed:|
      context "with style attribute" do
        let(:markdown) do
          "<span style=\"background-color: #000000\"></span>"
        end

        if allowed
          it "does not sanitize span element" do
            should eq "<p><span style=\"background-color: #000000\"></span></p>\n"
          end
        else
          it "sanitizes span element" do
            should eq "<p></p>\n"
          end
        end
      end
    end

    shared_examples_for "override embed code attributes" do |allowed:|
      context "with HTML embed code for CodePen using old script url" do
        let(:markdown) do
          <<-MARKDOWN.strip_heredoc
            <p data-height="1" data-theme-id="0" data-slug-hash="foo" data-default-tab="bar" data-user="baz" data-embed-version="2" data-pen-title="qux" class="codepen"></p>
            <script src="https://production-assets.codepen.io/assets/embed/ei.js"></script>
          MARKDOWN
        end

        if allowed
          it "does not sanitize embed code" do
            should eq <<-HTML.strip_heredoc
              <p data-height="1" data-theme-id="0" data-slug-hash="foo" data-default-tab="bar" data-user="baz" data-embed-version="2" data-pen-title="qux" class="codepen"></p>\n
              <script src="https://production-assets.codepen.io/assets/embed/ei.js"></script>
            HTML
          end
        else
          it "forces async attribute on script" do
            should eq <<-HTML.strip_heredoc
              <p data-height="1" data-theme-id="0" data-slug-hash="foo" data-default-tab="bar" data-user="baz" data-embed-version="2" data-pen-title="qux" class="codepen"></p>\n
              <script src="https://production-assets.codepen.io/assets/embed/ei.js" async="async"></script>
            HTML
          end
        end
      end

      context "with HTML embed code for CodePen" do
        let(:markdown) do
          <<-MARKDOWN.strip_heredoc
            <p data-height="1" data-theme-id="0" data-slug-hash="foo" data-default-tab="bar" data-user="baz" data-embed-version="2" data-pen-title="qux" class="codepen"></p>
            <script src="https://static.codepen.io/assets/embed/ei.js"></script>
          MARKDOWN
        end

        if allowed
          it "does not sanitize embed code" do
            should eq <<-HTML.strip_heredoc
              <p data-height="1" data-theme-id="0" data-slug-hash="foo" data-default-tab="bar" data-user="baz" data-embed-version="2" data-pen-title="qux" class="codepen"></p>\n
              <script src="https://static.codepen.io/assets/embed/ei.js"></script>
            HTML
          end
        else
          it "forces async attribute on script" do
            should eq <<-HTML.strip_heredoc
              <p data-height="1" data-theme-id="0" data-slug-hash="foo" data-default-tab="bar" data-user="baz" data-embed-version="2" data-pen-title="qux" class="codepen"></p>\n
              <script src="https://static.codepen.io/assets/embed/ei.js" async="async"></script>
            HTML
          end
        end
      end

      context "with HTML embed code for Asciinema" do
        let(:markdown) do
          <<-MARKDOWN.strip_heredoc
            <script id="example" src="https://asciinema.org/a/example.js"></script>
          MARKDOWN
        end

        if allowed
          it "does not sanitize embed code" do
            should eq <<-HTML.strip_heredoc
              <script id="example" src="https://asciinema.org/a/example.js"></script>
            HTML
          end
        else
          it "forces async attribute on script" do
            should eq <<-HTML.strip_heredoc
              <script id="example" src="https://asciinema.org/a/example.js" async="async"></script>
            HTML
          end
        end
      end

      context "with HTML embed code for Youtube" do
        shared_examples "embed code youtube example" do
          let(:markdown) do
            <<-MARKDOWN.strip_heredoc
              <iframe width="100" height="100" src="#{url}"></iframe>
            MARKDOWN
          end
          let(:url) { "#{scheme}//www.youtube.com/embed/example" }

          if allowed
            it "does not sanitize embed code" do
              should eq <<-HTML.strip_heredoc
                <iframe width="100" height="100" src="#{url}"></iframe>
              HTML
            end
          else
            it "forces width attribute on iframe" do
              should eq <<-HTML.strip_heredoc
                <iframe width="100%" height="100" src="#{url}"></iframe>
              HTML
            end
          end

          context "when url is privacy enhanced mode" do
            let(:markdown) do
              <<-MARKDOWN.strip_heredoc
                <iframe width="100" height="100" src="#{url}"></iframe>
              MARKDOWN
            end
            let(:url) { "#{scheme}//www.youtube-nocookie.com/embed/example" }

            if allowed
              it "does not sanitize embed code" do
                should eq <<-HTML.strip_heredoc
                  <iframe width="100" height="100" src="#{url}"></iframe>
                HTML
              end
            else
              it "forces width attribute on iframe" do
                should eq <<-HTML.strip_heredoc
                  <iframe width="100%" height="100" src="#{url}"></iframe>
                HTML
              end
            end
          end
        end

        context "with scheme" do
          let(:scheme) { "https:" }

          include_examples "embed code youtube example"
        end

        context "without scheme" do
          let(:scheme) { "" }

          include_examples "embed code youtube example"
        end
      end

      context "with HTML embed code for SlideShare" do
        shared_examples "embed code slideshare example" do
          let(:markdown) do
            <<-MARKDOWN.strip_heredoc
              <iframe width="100" height="100" src="#{url}"></iframe>
            MARKDOWN
          end
          let(:url) { "#{scheme}//www.slideshare.net/embed/example" }

          if allowed
            it "does not sanitize embed code" do
              should eq <<-HTML.strip_heredoc
                <iframe width="100" height="100" src="#{url}"></iframe>
              HTML
            end
          else
            it "forces width attribute on iframe" do
              should eq <<-HTML.strip_heredoc
                <iframe width="100%" height="100" src="#{url}"></iframe>
              HTML
            end
          end
        end

        context "with scheme" do
          let(:scheme) { "https:" }

          include_examples "embed code slideshare example"
        end

        context "without scheme" do
          let(:scheme) { "" }

          include_examples "embed code slideshare example"
        end
      end

      context "with HTML embed code for GoogleSlide" do
        shared_examples "embed code googleslide example" do
          let(:markdown) do
            <<-MARKDOWN.strip_heredoc
            <iframe src="#{url}" frameborder="0" width="482" height="300" allowfullscreen="true" mozallowfullscreen="true" webkitallowfullscreen="true"></iframe>
            MARKDOWN
          end
          let(:url) { "#{scheme}//docs.google.com/presentation/d/example/embed" }

          if allowed
            it "does not sanitize embed code" do
              should eq <<-HTML.strip_heredoc
              <iframe src="#{url}" frameborder="0" width="482" height="300" allowfullscreen="true"></iframe>
              HTML
            end
          else
            it "forces width attribute on iframe" do
              should eq <<-HTML.strip_heredoc
              <iframe src="#{url}" frameborder="0" width="100%" height="300" allowfullscreen="true"></iframe>
              HTML
            end
          end
        end

        context "with scheme" do
          let(:scheme) { "https:" }

          include_examples "embed code googleslide example"
        end

        context "without scheme" do
          let(:scheme) { "" }

          include_examples "embed code googleslide example"
        end
      end

      context "with HTML embed code for SpeekerDeck" do
        let(:markdown) do
          <<-MARKDOWN.strip_heredoc
            <script async class="speakerdeck-embed" data-id="example" data-ratio="1.33333333333333" src="//speakerdeck.com/assets/embed.js"></script>
          MARKDOWN
        end

        if allowed
          it "does not sanitize embed code" do
            should eq <<-HTML.strip_heredoc
              <script async class="speakerdeck-embed" data-id="example" data-ratio="1.33333333333333" src="//speakerdeck.com/assets/embed.js"></script>
            HTML
          end
        else
          it "forces async attribute on script" do
            should eq <<-HTML.strip_heredoc
              <script async class="speakerdeck-embed" data-id="example" data-ratio="1.33333333333333" src="//speakerdeck.com/assets/embed.js"></script>
            HTML
          end
        end
      end

      context "with embed code for Tweet" do
        let(:markdown) do
          <<-MARKDOWN.strip_heredoc
            <blockquote class="twitter-tweet" data-lang="es" data-cards="hidden" data-conversation="none">foo</blockquote>
            <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>
          MARKDOWN
        end

        it "does not sanitize embed code" do
          should eq <<-HTML.strip_heredoc
            <blockquote class="twitter-tweet" data-lang="es" data-cards="hidden" data-conversation="none">foo</blockquote>\n
            <script async src="https://platform.twitter.com/widgets.js"></script>
          HTML
        end
      end

      context "with embed script code with xss" do
        let(:markdown) do
          <<-MARKDOWN.strip_heredoc
            <script async class="speakerdeck-embed" data-id="example" data-ratio="1.33333333333333" src="javascript://speakerdeck.com/assets/embed.js"></script>
          MARKDOWN
        end

        if allowed
          it "does not sanitize embed code" do
            should eq markdown
          end
        else
          it "forces width attribute on iframe" do
            should eq "\n"
          end
        end
      end

      context "with embed iframe code with xss" do
        let(:markdown) do
          <<-MARKDOWN.strip_heredoc
            <iframe src="javascript://docs.google.com:80/%0d%0aalert(document.domain)" frameborder="0" width="482" height="300" allowfullscreen="true" mozallowfullscreen="true" webkitallowfullscreen="true"></iframe>
          MARKDOWN
        end

        if allowed
          it "does not sanitize embed code" do
            should eq <<-HTML.strip_heredoc
              <iframe src="javascript://docs.google.com:80/%0d%0aalert(document.domain)" frameborder="0" width="482" height="300" allowfullscreen="true"></iframe>
            HTML
          end
        else
          it "forces width attribute on iframe" do
            should eq "\n"
          end
        end
      end
    end

    shared_examples_for "custom block" do |allowed:|
      context "with custom block" do
        let(:type) { "" }
        let(:subtype) { "" }

        let(:markdown) do
          <<-MARKDOWN.strip_heredoc
            :::#{[type, subtype].join(' ').rstrip}
            Some kind of text is here.
            :::
          MARKDOWN
        end

        context "when type is not allowed" do
          let(:type) { "anytype" }

          if allowed
            it "returns simple div element" do
              should eq <<-HTML.strip_heredoc
                <div data-type="customblock" data-metadata="anytype">Some kind of text is here.
                </div>
              HTML
            end
          else
            it "returns simple div element" do
              should eq <<-HTML.strip_heredoc
                <div>Some kind of text is here.
                </div>
              HTML
            end
          end
        end

        context "when type is note" do
          let(:type) { "note" }

          context "when subtype is empty" do
            if allowed
              it "returns info note block with class including icon as default type" do
                should eq <<-HTML.strip_heredoc
                  <div data-type="customblock" data-metadata="note" class="note info">
                  <span class="fa fa-fw fa-check-circle"></span><p>Some kind of text is here.
                  </p>
                  </div>
                HTML
              end
            else
              it "returns note block with class including icon" do
                should eq <<-HTML.strip_heredoc
                  <div class="note info">
                  <span class="fa fa-fw fa-check-circle"></span><p>Some kind of text is here.
                  </p>
                  </div>
                HTML
              end
            end
          end

          context "when subtype is warn" do
            let(:subtype) { "warn" }

            if allowed
              it "returns warning note block with class including icon" do
                should eq <<-HTML.strip_heredoc
                  <div data-type="customblock" data-metadata="note warn" class="note warn">
                  <span class="fa fa-fw fa-exclamation-circle"></span><p>Some kind of text is here.
                  </p>
                  </div>
                HTML
              end
            else
              it "returns note block with class including icon" do
                should eq <<-HTML.strip_heredoc
                  <div class="note warn">
                  <span class="fa fa-fw fa-exclamation-circle"></span><p>Some kind of text is here.
                  </p>
                  </div>
                HTML
              end
            end
          end

          context "when subtype is alert" do
            let(:subtype) { "alert" }

            if allowed
              it "returns alerting note block with class including icon" do
                should eq <<-HTML.strip_heredoc
                  <div data-type="customblock" data-metadata="note alert" class="note alert">
                  <span class="fa fa-fw fa-times-circle"></span><p>Some kind of text is here.
                  </p>
                  </div>
                HTML
              end
            else
              it "returns note block with class including icon" do
                should eq <<-HTML.strip_heredoc
                  <div class="note alert">
                  <span class="fa fa-fw fa-times-circle"></span><p>Some kind of text is here.
                  </p>
                  </div>
                HTML
              end
            end
          end
        end
      end
    end

    context "without script and strict context" do
      let(:context) do
        super().merge(script: false, strict: false)
      end

      include_examples "basic markdown syntax"
      include_examples "script element", allowed: false
      include_examples "malicious script in filename", allowed: false
      include_examples "iframe element", allowed: false
      include_examples "input element", allowed: true
      include_examples "data-attributes", allowed: false
      include_examples "class attribute", allowed: true
      include_examples "background-color", allowed: true
      include_examples "override embed code attributes", allowed: false
      include_examples "custom block", allowed: false
    end

    context "with script context" do
      let(:context) do
        super().merge(script: true, strict: false)
      end

      include_examples "basic markdown syntax"
      include_examples "script element", allowed: true
      include_examples "malicious script in filename", allowed: true
      include_examples "iframe element", allowed: true
      include_examples "input element", allowed: true
      include_examples "data-attributes", allowed: true
      include_examples "class attribute", allowed: true
      include_examples "background-color", allowed: true
      include_examples "override embed code attributes", allowed: true
      include_examples "custom block", allowed: true
    end

    context "with strict context" do
      let(:context) do
        super().merge(script: false, strict: true)
      end

      include_examples "basic markdown syntax"
      include_examples "script element", allowed: false
      include_examples "malicious script in filename", allowed: false
      include_examples "iframe element", allowed: false
      include_examples "input element", allowed: false
      include_examples "data-attributes", allowed: false
      include_examples "class attribute", allowed: false
      include_examples "background-color", allowed: false
      include_examples "override embed code attributes", allowed: false
      include_examples "custom block", allowed: false
    end

    context "with script and strict context" do
      let(:context) do
        super().merge(script: true, strict: true)
      end

      include_examples "basic markdown syntax"
      include_examples "script element", allowed: false
      include_examples "malicious script in filename", allowed: true
      include_examples "iframe element", allowed: false
      include_examples "input element", allowed: false
      include_examples "data-attributes", allowed: false
      include_examples "class attribute", allowed: false
      include_examples "background-color", allowed: false
      include_examples "override embed code attributes", allowed: false
      include_examples "custom block", allowed: true
    end
  end
end
