# Qiita::Markdown
Qiita-specified markdown renderer.

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
Processor takes optional context as a Hash which is shared by all filters.

```ruby
processor = Qiita::Markdown::Processor.new(asset_root: "http://example.com/assets")
processor.call(text, asset_root: "http://cdn.example.com")
```
