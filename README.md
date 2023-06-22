# Bidify (Ruby)

Bidify helps to add bidirectional text support to HTML documents.

The project is in its very early stage of development and its interface or functionality may break from one version to another. Use it with caution.

## Usage

```rb
require 'bidify'

html_input = '<p>some content even in nested format</p>'
bidified_html = Bidify.bidify(html_input)
# bidified_html: '<p dir="auto">some content even in nested format</p>' 
```

## License

This project is a Free/Libre and Open Source software released under LGPLv3 license.
