# Bidify (Ruby)

Bidify helps to add bidirectional text support to HTML documents.

The project is in its very early stage of development, and its interface or
functionality may break from one version to another. Use it with caution.

## Usage

```rb
require 'bidify'

html_input = '<p>some content even in nested format</p>'
bidified_html = Bidify.bidify_html_string(html_input)
# bidified_html: '<p dir="auto">some content even in nested format</p>' 
```

## Rules

Bidification (the `dir="auto"` attribute) follows these simple rules:

- It applies to "bidifiable" tags.
- It excludes the first immediate child element.
- It excludes `li` tags.

The default bidifiable tags are `div`, `h1`, `h2`, `h3`, `h4`, `h5`, `h6`,
`p`, `ul`, `ol`, and `blockquote`. One can modify this list using options.

As a complementary step, CSS styles should use [logical properties](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_logical_properties_and_values). Here are a few examples:

```css
/* Physical properties */
text-align: left;
padding-right: 10px;
border-left: 1px;
/* Logical properties */
text-align: start;
padding-inline-end: 10px;
border-inline-start: 1px;
```

## Configuration

To use this gem with custom configuration, use the following syntax and pass
options while creating an instance of bidifier:

```rb
options = {
  # ...
}

bidifier = Bidify::HtmlStringBidifier.new(options)

puts bidifier.apply('<div>input stringified html</div>')
```

### Options

Available options with their default values are as follows:

- `greedy: false`

    By default, bidification stops when it reaches an element that has `dir`
    attribute. Use `true` to disregard any existing `dir` attributes.

- `with_table_support: false`

    Use `true` to add table tags support.

## License

This project is a Free/Libre and Open Source software released under LGPLv3
license.
