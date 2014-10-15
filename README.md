# Qiita::Markdown [![Build Status](https://travis-ci.org/increments/qiita-markdown.svg)](https://travis-ci.org/increments/qiita-markdown)
Qiita-specified markdown processor.

* Markdown conversion
* Sanitization
* Code and language detection
* Task list
* ToC
* Emoji
* Syntax highlighting
* Mention

## Usage
Qiita::Markdown::Processor provides markdown rendering logic.

```ruby
processor = Qiita::Markdown::Processor.new
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
Qiita::Markdown is built on [jch/html-pipeline](https://github.com/jch/html-pipeline).
Add your favorite html-pipeline-compatible filters.

```ruby
processor = Qiita::Markdown::Processor.new
processor.filters << HTML::Pipeline::ImageMaxWidthFilter
processor.call(text)
```

### Context
`.new` and `#call` can take optional context as a Hash with following keys:

```
allowed_usernames - A list of usernames allowed to be username. (Array<String>)
asset_path        - URL path to link to emoji sprite. (String)
asset_root        - Base URL to link to emoji sprite. (String)
base_url          - Used to construct links to user profile pages for each. (String)
default_language  - Default language used if no language detected from code. (String)
language_aliases  - Alias table for some language names. (Hash)
rule              - Sanitization rule table. (Hash)
script            - A flag to allow to embed script element. (Boolean)
```

```ruby
processor = Qiita::Markdown::Processor.new(asset_root: "http://example.com/assets")
processor.call(text)
```
