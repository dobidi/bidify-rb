# Bidify (Ruby)

[![Gem Version](https://badge.fury.io/rb/bidify.svg)](https://badge.fury.io/rb/bidify)

Bidify helps to add bidirectional text support to HTML documents.

The project is in its very early stage of development and its interface or functionality may break from one version to another. Use it with caution.

## Usage

```rb
require 'bidify'

html_input = '<div>some content even in nested format</div>'
bidified_html = Bidify.bidify(html_input)
```

## License

This project is a Free/Libre and Open Source software released under LGPLv3 license.
