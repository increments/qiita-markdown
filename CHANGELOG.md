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
