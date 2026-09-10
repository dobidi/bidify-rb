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

Bidification adds `dir="auto"` to block-level elements based on a **post-order depth-first traversal** of the HTML fragment.

### Core Algorithm

For each parent element, the algorithm tracks whether it has seen its **first actual content child** (reset per parent). For each child in document order:

1. **Skip** if child has a `dir` attribute (unless `greedy: true`)
2. **Recurse** into child first
3. **Add `dir="auto"`** to child **iff**:
   - Parent is the root fragment (`is_root=true`), **OR**
   - Parent has already seen its first actual content child (`seen_first=true`)
   - **AND** child's tag is in the bidifiable tags set
4. **Mark `seen_first=true`** if child is an element **or** non-blank text node

### What Counts as "Actual Content"

- ✅ Element nodes (`<p>`, `<div>`, etc.)
- ✅ Non-blank text nodes (`"hello"`, `" مرحبا "`)
- ❌ Blank text nodes (whitespace only: `"\n"`, `"  "`)
- ❌ Comments (`<!-- comment -->`)

### Default Bidifiable Tags

`div`, `h1`–`h6`, `p`, `ul`, `ol`, `blockquote`

> **Note**: `li` is not bidifiable by default (not in default tags), but can be enabled via `including_tags` or `only_tags`.

### Key Behaviors

| Scenario | Result |
|----------|--------|
| `<div><p>A</p><p>B</p></div>` | `<div dir="auto"><p>A</p><p dir="auto">B</p></div>` — first `<p>` skipped |
| `<div>text<p>A</p></div>` | `<div dir="auto">text<p dir="auto">A</p></div>` — text = first content |
| `<div><div><p>X</p></div></div>` | `<div dir="auto"><div><p>X</p></div></div>` — only root (single-child chain) |
| `<div dir="ltr"><p>A</p></div>` | Unchanged — existing `dir` blocks recursion |
| Same + `greedy: true` | `<div dir="auto"><p>A</p></div>` — ignores existing `dir` |

### How It Works (Decision Flow)

```
For each parent node:
  seen_first = false
  For each child in order:
    if child has dir attr and not greedy: continue
    recurse(child)
    if (is_root OR seen_first) AND child.tag in bidifiable_tags:
      child.dir = "auto"
    if child is element OR (child is text AND not blank):
      seen_first = true
```

### Fragment Parsing

Input is treated as an **HTML fragment** (not a full document):
- No `<html>`, `<head>`, `<body>` added
- Multiple root-level siblings processed independently
- Each root element gets `dir="auto"` (first content at fragment level)

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

- `excluding_tags: []`

    Removes tags from the list of bidifiable tags. This option affects the
    provided tags in `including_tags` options.

- `including_tags: []`

    Adds new tags to the list of bidifiable tags

- `greedy: false`

    By default, bidification stops when it reaches an element that has `dir`
    attribute. Use `true` to disregard any existing `dir` attributes.

- `only_tags: []`

    It sets the bidifiable tags to the given tags.

- `with_table_support: false`

    Use `true` to add table tags support.

## Documentation

- **Implementation guide**: `docs/implementation/guide.md` — Language-agnostic spec
- **AI agent reference**: `docs/ai-agent-guide.md` — Token-efficient quick reference
- **Full test matrix**: `docs/reference/test-matrix.md` — 35+ compliance tests
- **All docs**: `docs/README.md`

## License

This project is a Free/Libre and Open Source software released under LGPLv3
license.
