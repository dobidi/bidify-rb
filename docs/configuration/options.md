# Configuration Options

This document describes all configuration options for controlling the bidification behavior.

## Options Object

All options are passed as a single configuration object/hash to the bidifier constructor.

## Option Reference

### `with_table_support` (Boolean)

**Default**: `false`

Enables bidification of HTML table elements.

When `true`, adds these tags to the bidifiable set:
- `table`, `thead`, `tbody`, `th`, `tr`, `td`

**Example**:
```ruby
bidifier = HtmlStringBidifier.new(with_table_support: true)
bidifier.apply('<table><tr><td>Content</td></tr></table>')
# => <table dir="auto"><tr><td>Content</td></tr></table>
```

---

### `including_tags` (Array<String>)

**Default**: `[]`

Additional tag names to include in bidification. These are **added** to the default set.

**Example**:
```ruby
bidifier = HtmlStringBidifier.new(including_tags: ['span', 'section'])
bidifier.apply('<span>text</span><section>text</section>')
# => <span dir="auto">text</span><section dir="auto">text</section>
```

---

### `excluding_tags` (Array<String>)

**Default**: `[]`

Tag names to exclude from bidification. These are **removed** from the effective bidifiable set (after defaults and `including_tags` are applied).

**Example**:
```ruby
bidifier = HtmlStringBidifier.new(excluding_tags: ['blockquote'])
bidifier.apply('<blockquote>quote</blockquote><p>text</p>')
# => <blockquote>quote</blockquote><p dir="auto">text</p>
```

**Priority**: `excluding_tags` overrides `including_tags` if the same tag appears in both.

---

### `only_tags` (Array<String>)

**Default**: `null` (use defaults)

**Mutually exclusive** with `including_tags` and `excluding_tags`.

Restricts bidification to **exactly** the specified tags. Default tags are ignored.

**Example**:
```ruby
bidifier = HtmlStringBidifier.new(only_tags: ['p', 'h1'])
bidifier.apply('<p>para</p><div>div</div><h1>heading</h1>')
# => <p dir="auto">para</p><div>div</div><h1 dir="auto">heading</h1>
```

---

### `greedy` (Boolean)

**Default**: `false`

When `true`, ignores existing `dir` attributes on elements. The algorithm will:
- Recurse into elements that already have `dir` set
- Overwrite existing `dir` values with `"auto"` on qualifying elements

When `false` (default), elements with existing `dir` attributes:
- Act as recursion boundaries (algorithm stops descending)
- Retain their original `dir` value

**Example** (non-greedy, default):
```ruby
input = '<div><p>1</p><div dir="ltr"><p>2</p><p>3</p></div></div>'
# Output:
# <div dir="auto"><p>1</p><div dir="ltr"><p>2</p><p>3</p></div></div>
```

**Example** (greedy):
```ruby
bidifier = HtmlStringBidifier.new(greedy: true)
input = '<div><p>1</p><div dir="ltr"><p>2</p><p>3</p></div></div>'
# Output:
# <div dir="auto"><p>1</p><div dir="auto"><p>2</p><p dir="auto">3</p></div></div>
```

## Option Precedence

When multiple options interact:

1. **`only_tags`** wins - if present, all other tag options are ignored
2. **`excluding_tags`** overrides **`including_tags`** - tags in both lists are excluded
3. **`with_table_support`** adds table tags to whatever the current effective set is
4. **`greedy`** is independent - affects recursion behavior only

## Effective Bidifiable Tags Calculation

```
IF only_tags is set:
    effective_tags = only_tags
ELSE:
    effective_tags = DEFAULT_TAGS
    IF with_table_support:
        effective_tags += TABLE_TAGS
    IF including_tags:
        effective_tags += including_tags
    IF excluding_tags:
        effective_tags -= excluding_tags
```

## Validation Rules

Implementations SHOULD validate:
- `including_tags`, `excluding_tags`, `only_tags` must be arrays of strings
- Tag names should be lowercase (HTML standard)
- `only_tags` cannot be used with `including_tags` or `excluding_tags` (error or warning)
- Unknown options should be ignored or raise error