# Edge Cases and Special Behaviors

This document describes all edge cases, special behaviors, and test-verified scenarios that any compliant implementation must handle correctly.

## 1. First Content Element Skipping

### Nested Elements - First Child Skipped

```html
<!-- Input -->
<blockquote>
  <p>Item 1</p>
  <p>Item 2</p>
</blockquote>

<!-- Output -->
<blockquote dir="auto">
  <p>Item 1</p>
  <p dir="auto">Item 2</p>
</blockquote>
```

**Rule**: The first `<p>` is the first actual content child of `<blockquote>`, so it's skipped. The second `<p>` gets `dir="auto"`.

### Plain Text as First Content

```html
<!-- Input -->
<blockquote>
  blah
  <p>Item 1</p>
  <p>Item 2</p>
</blockquote>

<!-- Output -->
<blockquote dir="auto">
  blah
  <p dir="auto">Item 1</p>
  <p dir="auto">Item 2</p>
</blockquote>
```

**Rule**: The text node "blah" counts as actual content, so it becomes the "first content" and the `<blockquote>` gets `dir="auto"`. Then both `<p>` elements (being subsequent bidifiable siblings) also get `dir="auto"`.

### HTML Comments Don't Count as Content

```html
<!-- Input -->
<blockquote>
  <!-- comment -->
  <p>Item 1</p>
  <p>Item 2</p>
</blockquote>

<!-- Output -->
<blockquote dir="auto">
  <!-- comment -->
  <p>Item 1</p>
  <p dir="auto">Item 2</p>
</blockquote>
```

**Rule**: Comments are not "actual content", so the first `<p>` becomes the first content element (skipped), second gets `dir="auto"`.

### Blank Lines Don't Count as Content

```html
<!-- Input -->
<blockquote>

  <p>Item 1</p>
  <p>Item 2</p>
</blockquote>

<!-- Output -->
<blockquote dir="auto">

  <p>Item 1</p>
  <p dir="auto">Item 2</p>
</blockquote>
```

**Rule**: Whitespace-only text nodes are "blank" and don't count as actual content.

## 2. List Elements (ul, ol) Special Handling

### `<li>` Elements Never Bidified by Default

```html
<!-- Input -->
<ul>
  <li>Item 1<p>with paragraph</p></li>
  <li><p>Paragraph at beginning</p>Item 2</li>
</ul>

<!-- Output -->
<ul dir="auto">
  <li>Item 1<p dir="auto">with paragraph</p></li>
  <li><p>Paragraph at beginning</p>Item 2</li>
</ul>
```

**Key Observations**:
- `<ul>` gets `dir="auto"` (it's bidifiable)
- `<li>` never gets `dir="auto"` (not in default bidifiable tags)
- Nested `<p>` inside first `<li>`: the text "Item 1" is first content, so `<p>` is subsequent → gets `dir="auto"`
- Nested `<p>` in second `<li>`: `<p>` is first content (contains text), so it's skipped; "Item 2" text after is not an element

## 3. Explicit `dir` Attribute Boundaries

### Non-Greedy Mode (Default)

```html
<!-- Input -->
<div>
  <p>Item 1</p>
  <div dir="ltr">
    <p>Item 2</p>
    <p>Item 3</p>
  </div>
</div>

<!-- Output -->
<div dir="auto">
  <p>Item 1</p>
  <div dir="ltr">
    <p>Item 2</p>
    <p>Item 3</p>
  </div>
</div>
```

**Rule**: The inner `<div dir="ltr">` has an explicit `dir` attribute, so:
- Recursion stops at that element (children not processed)
- The inner `<div>` retains `dir="ltr"`
- No `dir="auto"` added to inner elements

### Greedy Mode

```html
<!-- Input (same) -->
<div>
  <p>Item 1</p>
  <div dir="ltr">
    <p>Item 2</p>
    <p>Item 3</p>
  </div>
</div>

<!-- Output with greedy: true -->
<div dir="auto">
  <p>Item 1</p>
  <div dir="auto">
    <p>Item 2</p>
    <p dir="auto">Item 3</p>
  </div>
</div>
```

**Rule**: With `greedy: true`, existing `dir` attributes are ignored:
- Recursion continues into the inner `<div>`
- Inner `<div>` gets `dir="auto"` (overwrites `ltr`)
- First `<p>` inside is first content → skipped
- Second `<p>` gets `dir="auto"`

## 4. Table Handling (with_table_support: true)

### Table Structure

```html
<!-- Input -->
<table>
  <tr>
    <td>راست left</td>
    <td>left راست</td>
  </tr>
</table>

<!-- Output -->
<table dir="auto">
  <tr>
    <td>راست left</td>
    <td dir="auto">left راست</td>
  </tr>
</table>
```

**Observations**:
- `<table>` gets `dir="auto"` (first content child is `<tr>`)
- `<tr>` is bidifiable but is first content child of `<table>` → skipped
- First `<td>` is first content child of `<tr>` → skipped
- Second `<td>` is subsequent bidifiable sibling → gets `dir="auto"`
- `<thead>`, `<tbody>`, `<th>` follow same rules

## 5. Non-Bidifiable Tags

These tags are **never** bidified by default:
- Inline: `span`, `a`, `img`, `strong`, `em`, etc.
- Semantic: `main`, `section`, `aside`, `header`, `footer`, `nav`, `article`
- Form: `input`, `button`, `select`, `textarea`, `form`
- Media: `video`, `audio`, `canvas`, `svg`
- Other: `script`, `style`, `meta`, `link`, `br`, `hr`

```html
<!-- Input -->
<span>Not getting affected</span>
<img src="image.png">
<main>content</main>
<section>content</section>
<aside>content</aside>
<a>content</a>

<!-- Output (unchanged) -->
<span>Not getting affected</span>
<img src="image.png">
<main>content</main>
<section>content</section>
<aside>content</aside>
<a>content</a>
```

## 6. Mixed Content Scenarios

### Elements with Only Text Content

```html
<!-- Input -->
<div>plain text</div>

<!-- Output -->
<div dir="auto">plain text</div>
```

**Rule**: The `<div>` is the root's first content child, but since it's the root level, `is_root=true` applies, so it gets `dir="auto"`.

### Deeply Nested Structures (Single Child Chain)

```html
<!-- Input -->
<div>
  <div>
    <div>
      <p>Deep</p>
    </div>
  </div>
</div>

<!-- Output -->
<div dir="auto"><div><div><p>Deep</p></div></div></div>
```

**Rule**: The `seen_the_first_bidifiable_element` flag is **local to each recursive call** (reset for each parent). Since each nested `<div>` has only one child (the next `<div>`), that child is always the "first actual content" and gets skipped. Only the outermost `<div>` (at root level with `is_root=true`) receives `dir="auto"`.

### Deeply Nested Structures (With Siblings)

```html
<!-- Input -->
<div>
  <div>A</div>
  <div>B</div>
</div>
<div>
  <div>C</div>
  <div>D</div>
</div>

<!-- Output -->
<div dir="auto">
  <div>A</div>
  <div dir="auto">B</div>
</div>
<div dir="auto">
  <div>C</div>
  <div dir="auto">D</div>
</div>
```

**Rule**: When a parent has multiple bidifiable children, the first is skipped (first actual content), and subsequent siblings get `dir="auto"`. This applies independently at each nesting level.

## 7. Fragment vs Document Parsing

The algorithm operates on **HTML fragments**, not full documents:
- No `<html>`, `<head>`, `<body>` added
- Input/output are fragment strings
- Multiple root-level siblings are processed independently

```html
<!-- Input (multiple roots) -->
<p>First</p>
<div>Second</div>

<!-- Output -->
<p dir="auto">First</p>
<div dir="auto">Second</div>
```

Each root-level element is treated as first content of the fragment → both get `dir="auto"`.

## 8. Attribute Preservation

- Only `dir` attribute is modified (added or overwritten in greedy mode)
- All other attributes preserved exactly
- Attribute order preserved
- No new attributes added

## 9. Case Sensitivity

- Tag names matched case-insensitively (HTML standard)
- Configuration tag names should be normalized to lowercase
- Output tag names preserve input casing (or normalize to lowercase)

## 10. Encoding and Special Characters

- Algorithm operates on parsed DOM, not raw strings
- Unicode/bidirectional characters in text content don't affect algorithm
- `dir="auto"` lets browser determine direction from content
- No content analysis performed - purely structural