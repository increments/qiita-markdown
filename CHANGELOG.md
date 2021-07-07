## Unreleased

## 0.37.0
- Change keyword of notation

## 0.36.0
- Support message notation

## 0.35.0

- Allow Relative URL in iframe src attributes

## 0.34.0

- Delete gist embed rule to avoid XSS

## 0.33.0

- Fix XSS possibility bug

## 0.32.0

- Fix XSS possibility bug
- Fix iframe width to be fixed at 100%

## 0.31.0

- Use greenmat 3.5.1.1

## 0.30.0

- Use greenmat 3.5.1.0

## 0.29.0

- Accept new embeded script and iframes
    - Gist
    - Youtube
    - SlideShare
    - SpeekerDeck
    - GoogleSlide

## 0.28.0

- Accept new codepen script url (cpwebassets.codepen.io)

## 0.27.0

- Support embed Asciinema

## 0.26.0

- Use greenmat 3.2.2.4

## 0.25.0

- Accept new codepen script url (static.codepen.io)

## 0.24.0

- Fix to strip HTML tags in ToC
- Allow to use data-\* attributes when embedding Tweet and CodePen

## 0.23.0

- Support embed Tweet

## 0.22.0

- Support embed CodePen

## 0.21.0

- Rename `Code` to `CodeBlock`
- Support CSS color in inline code

## 0.20.1

- Fix to sanitize `<input>` which was unexpectedly permitted

## 0.20.0

- Allow `<blockquote class="twitter-tweet">`

## 0.19.1

- Add missing sanitization for `<div>` class attribute

## 0.19.0

- Drop 2.0 and 2.1 from support Ruby versions
- Rename `Sanitize` as `FinalSanitizer`
- Add `:strict` context for stricter sanitization

## 0.18.0

- Extract heading decoration logic from Greenmat renderer to `Toc` filter
- Use greenmat 3.2.2.3

## 0.17.0

- Require pygments.rb 1.0 or later
- Remove superfluous leading newline in rendered HTML with pygments.rb 1.0

## 0.16.2

- Add timeout support to `SyntaxHighlightFilter`
- Make `SyntaxHighlightFilter` process code blocks faster when their specified language is unknown to Pygments

## 0.16.1

- Fix a group mention bug that unexpectedly removes preceding space

## 0.16.0

- Add rel=noopener to all external a tags
- Support HTML5 `<details>` and `<summary>` elements
- Enable to change settings for footnotes

## 0.15.0

- Append `rel=nofollow` and `target=_blank` to `a` tags for external link

## 0.14.0

- Add some attributes to mentions for rendering hovercard

## 0.13.0

- Support group mention

## 0.12.0

- Add custom emoji support via `:emoji_names` and `:emoji_url_generator` contexts

## 0.11.5

- Add a leading newline to `<pre>` elements so that leading newlines inputted by user are properly rendered on browsers

## 0.11.4

- Avoid stripping leading and trailing newlines in code snippets

## 0.11.3

- Ignore menton in blockquote element

## 0.11.2

- Support video element on `SCRIPTABLE_RULE`

## 0.11.1

- Support email address link

## 0.11.0

- Add `autolink` class to autolink element
- Remove activesupport runtime dependency

## 0.10.0

- Add ImageLink filter

## 0.9.0

- Support html-pipeline v2

## 0.8.1

- Fix filters configurations (thx @imishinist)

## 0.8.0

- Sanitize data-attributes

## 0.7.1

- Support mentions to 2-character usernames

## 0.7.0

- Support `@all`

## 0.6.0

- Add `:escape_html` extension to Qiita::Markdown::Greenmat::HTMLToCRenderer.
- Fix backward incompatibility of fragment identifier of heading that includes special HTML characters in v0.5.0.

## 0.5.0

- Add renderers Qiita::Markdown::Greenmat::HTMLRenderer and Qiita::Markdown::Greenmat::HTMLToCRenderer which can be passed to `Redcarpet::Markdown.new` and generate consistent heading fragment identifiers.

## 0.4.2

- Fix bug on SummaryProcessor with mention

## 0.4.1

- Ignore mention in filename label

## 0.4.0

- Replace the core renderer redcarpet with greenmat, which is a fork of redcarpet.
- Fix a bug where mentions with username including underscores (e.g. `@_username_`) was wrongly emphasized.

## 0.3.0

- Introduce another processor Qiita::Markdown::SummaryProcessor, which is for rendering a summary of markdown document.

## 0.2.2

- Fix a bug that raised error on rendering `<a>` tag with href for unknown fragment inside of `<sup>` tag (e.g. `<sup><a href="#foo.1">Link</a></sup>`)

## 0.2.1

- Strengthen sanitization (thx xrekkusu)

## 0.2.0

- Support text-align style on table syntax (thx @uribou)

## 0.1.9

- Fix a bug that raised error while rendering links with absolute URI inside of `<sup>` tag (e.g. `<sup>[Qiita](http://qiita.com/)</sup>`)

## 0.1.8

- Add title attribute into footnote link element

## 0.1.7

- Enable footnotes markdown syntax

## 0.1.6

- Add missing dependency on pygments.rb (thx @kwappa)

## 0.1.5

- Memoize Redcarpet::Markdown object

## 0.1.4

- Support type attribute of script element

## 0.1.3

- Support text-align syntax on table

## 0.1.2

- Support rowspan attribute

## 0.1.1

- Support empty list

## 0.1.0

- Default to add disabled attribute to checkbox

## 0.0.9

- Make it Ruby 2.0.0-compatible

## 0.0.8

- Support gapped task list

## 0.0.7

- Change dependent gem version

## 0.0.6

- Remove target="_blank" from a element of mention

## 0.0.5

- Allow font element with color attribute

## 0.0.4

- Add iframe and data-attributes support

## 0.0.3

- Fix bug of code block that has colon-only label

## 0.0.2

- Remove version dependency on gemoji

## 0.0.1

- 1st Release
