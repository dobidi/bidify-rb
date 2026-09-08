# Quick Reference

## Default Bidifiable Tags

| Category | Tags |
|----------|------|
| Headings | h1, h2, h3, h4, h5, h6 |
| Block | div, p, blockquote |
| Lists | ul, ol |

## Table Tags (with_table_support)

table, thead, tbody, th, tr, td

## Configuration Options Quick Table

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `with_table_support` | bool | false | Enable table tag bidification |
| `including_tags` | string[] | [] | Add tags to bidifiable set |
| `excluding_tags` | string[] | [] | Remove tags from bidifiable set |
| `only_tags` | string[] | null | Restrict to only these tags |
| `greedy` | bool | false | Ignore existing dir attributes |

## First-Content Rule Summary

| Scenario | First Child | Gets dir="auto"? |
|----------|-------------|------------------|
| Element | `<p>text</p>` | ❌ (skipped) |
| Non-blank text | `hello` | ✅ (parent gets it) |
| Blank text | `  \n  ` | ❌ (ignored) |
| Comment | `<!-- c -->` | ❌ (ignored) |
| Subsequent bidifiable sibling | `<p>2nd</p>` | ✅ |

## Recursion Stop Conditions

| Mode | Element with dir="ltr" | Element with dir="auto" | Element with dir="rtl" |
|------|------------------------|-------------------------|------------------------|
| Normal (greedy=false) | **STOP** - don't recurse | **STOP** - don't recurse | **STOP** - don't recurse |
| Greedy (greedy=true) | Continue - overwrite | Continue - overwrite | Continue - overwrite |

## Tag Name Matching

- Case-insensitive: `<DIV>`, `<Div>`, `<div>` all match `'div'`
- Configuration tags normalized to lowercase
- Output preserves input casing (or normalizes)

## Option Precedence

```
only_tags (highest)
    ↓
excluding_tags
    ↓
including_tags
    ↓
with_table_support
    ↓
DEFAULT_TAGS (lowest)
```

## Common Patterns

### Bidify everything (aggressive)
```ruby
Bidify::HtmlStringBidifier.new(
  only_tags: %w[div p span h1 h2 h3 h4 h5 h6 ul ol li blockquote table tr td th],
  greedy: true
)
```

### Conservative (only explicit blocks)
```ruby
Bidify::HtmlStringBidifier.new(
  only_tags: %w[p h1 h2 h3 h4 h5 h6 blockquote]
)
```

### Tables + custom tags
```ruby
Bidify::HtmlStringBidifier.new(
  with_table_support: true,
  including_tags: ['section', 'article']
)
```

## Output Guarantees

- ✅ Only adds/modifies `dir` attribute
- ✅ Preserves all other attributes
- ✅ Preserves attribute order
- ✅ Preserves whitespace in text nodes
- ✅ Preserves HTML comments
- ✅ Output is valid HTML fragment
- ❌ Does NOT add/remove elements
- ❌ Does NOT modify text content
- ❌ Does NOT add `<html>`, `<body>` wrapper