# Bidify — AI Agent Quick Reference

> **Purpose**: Token-efficient reference for implementing, debugging, or porting the bidify algorithm. Read this first.

---

## One-Paragraph Algorithm

**Post-order depth-first traversal** of an HTML fragment tree. At each parent, track `seen_first_content` (reset per parent). For each child: skip if it has `dir` attr (unless `greedy`); recurse; then add `dir="auto"` to child **iff** `(is_root OR seen_first_content) AND child.name ∈ bidifiable_tags`; finally set `seen_first_content = true` if child is an element or non-blank text.

---

## Constants

```ruby
DEFAULT_TAGS = %w[div h1 h2 h3 h4 h5 h6 p ul ol blockquote]
TABLE_TAGS   = %w[table thead tbody th tr td]
```

---

## Configuration

```ruby
config = {
  with_table_support: false,   # bool — add TABLE_TAGS to bidifiable set
  including_tags: [],          # string[] — additional tags
  excluding_tags: [],          # string[] — remove from bidifiable set
  only_tags: nil,              # string[] or nil — if set, IGNORES all above
  greedy: false                # bool — ignore existing dir attrs, recurse & overwrite
}
```

**Precedence**: `only_tags` → `excluding_tags` → `including_tags` → `with_table_support` → `DEFAULT_TAGS`

---

## Core Pseudocode

```python
def bidify(html_string, config):
    fragment = parse_fragment(html_string)
    state = compute_bidifiable_tags(config)
    _recurse(fragment, state, is_root=True)
    return serialize(fragment)

def _recurse(node, state, is_root):
    seen_first = False
    for child in node.children:
        if not state.greedy and child.has_attr('dir'):
            continue
        _recurse(child, state, is_root=False)
        if (is_root or seen_first) and child.name in state.bidifiable_tags:
            child.set_attr('dir', 'auto')
        if child.is_element or (child.is_text and not child.is_blank):
            seen_first = True
```

---

## Decision Logic for `dir="auto"`

```
FOR each child of current parent:
  1. IF stop_recursion?(child): CONTINUE
  2. RECURSE(child)
  3. IF (is_root OR seen_first_content) AND is_bidifiable?(child):
         SET child.dir = "auto"
  4. IF is_actual_content?(child):
         seen_first_content = TRUE
```

**`stop_recursion?(node)`**: `node.has_attr('dir')` unless `config.greedy == true`

**`is_actual_content?(node)`**: `node.is_element OR (node.is_text AND !node.is_blank)`

**`is_bidifiable?(node)`**: `node.is_element AND node.name.lowercase IN bidifiable_tags`

---

## Key Behaviors (Mental Model)

| Input Pattern | Output | Why |
|---------------|--------|-----|
| `<div><p>A</p><p>B</p></div>` | `<div dir="auto"><p>A</p><p dir="auto">B</p></div>` | First `<p>` is first content → skipped |
| `<div>text<p>A</p><p>B</p></div>` | `<div dir="auto">text<p dir="auto">A</p><p dir="auto">B</p></div>` | Text = first content → parent + both `<p>` get dir |
| `<div><!--c--><p>A</p><p>B</p></div>` | `<div dir="auto"><!--c--><p>A</p><p dir="auto">B</p></div>` | Comment ≠ content → first `<p>` skipped |
| `<div>\n<p>A</p><p>B</p></div>` | `<div dir="auto">\n<p>A</p><p dir="auto">B</p></div>` | Blank text ≠ content |
| `<div><div><div><p>X</p></div></div></div>` | `<div dir="auto"><div><div><p>X</p></div></div></div>` | Each level has 1 child → always "first" → skipped |
| `<div dir="ltr"><p>A</p></div>` | Unchanged (default) | Existing `dir` blocks recursion |
| Same + `greedy: true` | `<div dir="auto"><p>A</p></div>` | Greedy ignores existing `dir` |

---

## Minimal Test Cases (Must Pass)

```ruby
# 1. Basic
assert bidify('<p>x</p>') == '<p dir="auto">x</p>'

# 2. First-content skip (siblings)
assert bidify('<div><p>1</p><p>2</p></div>') == '<div dir="auto"><p>1</p><p dir="auto">2</p></div>'

# 3. Text as first content
assert bidify('<div>text<p>1</p><p>2</p></div>') == '<div dir="auto">text<p dir="auto">1</p><p dir="auto">2</p></div>'

# 4. Dir boundary (non-greedy)
assert bidify('<div><p>1</p><div dir="ltr"><p>2</p></div></div>') == '<div dir="auto"><p>1</p><div dir="ltr"><p>2</p></div></div>'

# 5. Greedy mode
assert bidify('<div><p>1</p><div dir="ltr"><p>2</p></div></div>', greedy: true) == '<div dir="auto"><p>1</p><div dir="auto"><p>2</p></div></div>'

# 6. only_tags
assert bidify('<p>x</p><div>y</div>', only_tags: ['p']) == '<p dir="auto">x</p><div>y</div>'
```

---

## Common Bugs Checklist

- [ ] `seen_first` **not reset per parent** (must be local to recursive call)
- [ ] `is_root` not passed/handled → root's first child incorrectly skipped
- [ ] `actual_content?` returns true for blank text or comments
- [ ] Tag matching not case-insensitive
- [ ] `only_tags` doesn't override `including_tags`/`excluding_tags`
- [ ] `excluding_tags` doesn't override `including_tags`
- [ ] Fragment parsing adds wrapper (`<html><body>`) — must use fragment parser
- [ ] Serialization loses attribute order or whitespace

---

## File Map (Ruby Reference)

| File | Purpose | Lines |
|------|---------|-------|
| `lib/bidify/bidifier.rb` | Core algorithm (configure, bidify_recursively, actual_content?, stop_recursion_at?) | 57 |
| `lib/bidify/html_string_bidifier.rb` | Entry point: parse fragment → recurse → serialize | 31 |
| `lib/bidify.rb` | Module API: `Bidify.bidify_html_string` | 27 |
| `spec/html_string_bidifier_spec.rb` | All 35+ test cases | 329 |

---

## Quick Commands

```bash
# Run tests
bundle exec rspec

# Manual test
ruby -e "require './lib/bidify'; puts Bidify.bidify_html_string('<div><p>a</p><p>b</p></div>')"

# Debug: add puts in bidify_recursively to trace seen_first per level
```

---

## Porting Checklist (New Language)

1. [ ] HTML fragment parser with node tree access
2. [ ] Node type detection: element, text, comment
3. [ ] `blank?` for text nodes (whitespace-only)
4. [ ] Attribute get/set/has
5. [ ] Post-order traversal with `is_root` flag
6. [ ] Config object with precedence logic
7. [ ] Run test matrix (reference: `docs/reference/test-matrix.md`)
8. [ ] Verify single-child-chain behavior (only root gets dir)

---

## Related Specs

- Unicode Bidi Algorithm: https://www.unicode.org/reports/tr9/
- HTML `dir` attribute: https://developer.mozilla.org/en-US/docs/Web/HTML/Global_attributes/dir
- Full docs: `docs/README.md`