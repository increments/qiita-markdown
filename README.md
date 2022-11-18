# Qiita Markdown

[![Gem Version](https://badge.fury.io/rb/qiita-markdown.svg)](https://badge.fury.io/rb/qiita-markdown)
[![Build Status](https://travis-ci.org/increments/qiita-markdown.svg)](https://travis-ci.org/increments/qiita-markdown)
[![Code Climate](https://codeclimate.com/github/increments/qiita-markdown/badges/gpa.svg)](https://codeclimate.com/github/increments/qiita-markdown)
[![Test Coverage](https://codeclimate.com/github/increments/qiita-markdown/badges/coverage.svg)](https://codeclimate.com/github/increments/qiita-markdown)

Qiita-specified markdown processor.

- Markdown conversion
- Sanitization
- Code and language detection
- Task list
- ToC
- Emoji
- Syntax highlighting
- Mention
- Footnotes
- Note notation's custom block

## Basic Usage

Qiita::Markdown::Processor provides markdown rendering logic.

```ruby
processor = Qiita::Markdown::Processor.new(hostname: "example.com")
processor.call(markdown)
# => {
#   codes: [
#     {
#       code: "1 + 1\n",
#       language: "ruby",
#       filename: "example.rb",
#     },
#   ],
#   mentioned_usernames: [
#     "alice",
#     "bob",
#   ],
#   output: "<h1>Example</h1>\n...",
# }
```

### Filters

Qiita Markdown is built on [jch/html-pipeline](https://github.com/jch/html-pipeline).
Add your favorite html-pipeline-compatible filters.

```ruby
processor = Qiita::Markdown::Processor.new(hostname: "example.com")
processor.filters << HTML::Pipeline::ImageMaxWidthFilter
processor.call(text)
```

### Context

`.new` and `#call` can take optional context as a Hash with following keys:

```
:allowed_usernames            - A list of usernames allowed to be username. (Array<String>)
:asset_path                   - URL path to link to emoji sprite. (String)
:asset_root                   - Base URL to link to emoji sprite. (String)
:base_url                     - Used to construct links to user profile pages for each. (String)
:default_language             - Default language used if no language detected from code. (String)
:emoji_names                  - A list of allowed emoji names. (Array<String>)
:emoji_url_generator          - #call'able object that accepts emoji name as argument and returns emoji image URL. (#call)
                                The original implementation is used when the generator returned a falsey value.
:hostname                     - FQDN. Used to check whether or not each URL of `href` attributes is external site. (String)
:inline_code_color_class_name - Class name for inline code color. (String)
:language_aliases             - Alias table for some language names. (Hash)
:markdown                     - A hash for enabling / disabling optional Markdown syntax. (Hash)
                                Currently :footnotes (default: true) and :sourcepos (defalut: false) are supported.
                                For more information on these options, please see [increments/qiita_marker](https://github.com/increments/qiita_marker).
:rule                         - Sanitization rule table. (Hash)
:script                       - A flag to allow to embed script element. (Boolean)
```

```ruby
processor = Qiita::Markdown::Processor.new(asset_root: "http://example.com/assets", hostname: "example.com")
processor.call(text)
```

## Rendering Summary

There's another processor Qiita::Markdown::SummaryProcessor,
which is for rendering a summary of markdown document.
It simplifies a document by removing complex markups
and also truncates it to a specific length without breaking the document structure.

Note that this processor does not produce the `:codes` output in contrast to the Processor.

### Context

SummaryProcessor accepts the following context in addition to the Processor's context:

```ruby
{
  truncate: {
    length: 100,  # Documents will be truncated if it exceeds this character count. (Integer)
    omission: '…' # A string added to the end of document when it's truncated. (String, nil)
  }
}
```

```ruby
processor = Qiita::Markdown::SummaryProcessor.new(truncate: { length: 80 }, hostname: "example.com")
processor.call(text)
```
