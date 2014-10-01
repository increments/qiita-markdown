# Qiita::Markdown
Qiita-specified markdown renderer.

## Usage
```ruby
processor = Qiita::Markdown::Processor.new
processor.filters << Your::Favorite::Filter # (optional)
processor.call(markdown) #=> {
#   codes: [
#     { code: "1 + 1", language: "ruby", filename: "example.rb" },
#   ],
#   mentioned_usernames: ["alice", "bob"],
#   output: "<h1>Example</h1>\n...",
# }
```
