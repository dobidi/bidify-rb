# Bidify (Ruby)

Bidify helps to add bidirectional text support to HTML documents.

The project is in its very early stage of development and its interface or functionality may break from one version to another. Use it with caution.

## Usage

```rb
require 'bidify'

html_input = '<p>some content even in nested format</p>'
bidified_html = Bidify.bidify_html_string(html_input)
# bidified_html: '<p dir="auto">some content even in nested format</p>' 
```

## Rules

The `dir="auto"` attribute should be applied on "bidifiable" tags as per the following rules:

- Only apply on "bidifiable" tags.
- All top-level elements
- All child elements except the first child

Bidifiable elements can be defined as per the use case requirements (not yet implemented).
The default bidifiable tags are: `div`, `h1`, `h2`, `h3`, `h4`, `h5`, `h6`, `p`, `ul`, `ol`, `blockquote`.

Notice that `li` elements shouldn't get `dir=auto` otherwise, the list appearance gets damaged.

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

The following is the list of options with their default values
- `greedy: false`

    By default, bidification stops when it reaches an element that has `dir`
    attribute. Use `true` to disregard any existing `dir` attributes.
- `with_table_support: false`

    Use `true` to add table tags support.

## License

This project is a Free/Libre and Open Source software released under LGPLv3 license.
