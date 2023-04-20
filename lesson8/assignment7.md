# Viewing Markdown Files

Markdown is a common text-to-html markup language. You've probably encountered it here on Launch School, on Stack Overflow, GitHub, and other popular sites already.

Converting raw Markdown text into HTML can be done with a variety of libraries, many of which are available for use with a Ruby application. We recommend you use Redcarpet in this project.

## Requirements

1. When a user views a document written in Markdown format, the browser should render the rendered HTML version of the document's content.

### My Implmentation

1. Add Redcarpet to Project
    1. Add `gem 'redcarpet'` to `Gemfile` and run `bundle install`
    2. Add `require 'redcarpet'` to top of `cms.rb`
2. In the `/:filename` path check the extension of the file name
    - If it is `.md`, render the output as html converted from markdown.
        1. Create a `Redcarpet::Markdown` instance passing `Redcarpet::Render::HTML` as an argument.
        2. call `render` on that instance and pass the contents of the markdown file.
    - If not, render as plaintext(see previous assignments)
3. Create Markdown file to test `data/about.md`. Include line `# Ruby is...`
4. Create test for markdown files `test_markdown`
    - Route to `/about.md`
    - Check that the Status code is `200`
    - Check that the `Content-Type` is correct `text/html;charset=utf-8`
    - Check that the body includes `'<h1>Ruby is...</h1>'`
