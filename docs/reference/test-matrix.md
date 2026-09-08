# Test Matrix for Bidify Compliance

This document lists all test cases that a compliant implementation must pass.

## Test Categories

### 1. Basic Bidification

| ID | Name | Input | Config | Expected Output |
|----|------|-------|--------|-----------------|
| B01 | Single paragraph | `<p>text</p>` | defaults | `<p dir="auto">text</p>` |
| B02 | All default block tags | `<div>x</div><h1>x</h1><h2>x</h2><h3>x</h3><h4>x</h4><h5>x</h5><h6>x</h6><p>x</p><blockquote>x</blockquote>` | defaults | All get `dir="auto"` |
| B03 | List containers | `<ul><li>x</li></ul><ol><li>x</li></ol>` | defaults | `<ul dir="auto">...`, `<ol dir="auto">...` |
| B04 | Non-bidifiable ignored | `<span>x</span><img><main>x</main><section>x</section><aside>x</aside><a>x</a>` | defaults | Unchanged |

### 2. First-Content Rule

| ID | Name | Input | Config | Expected Output |
|----|------|-------|--------|-----------------|
| F01 | Nested same tag - element first | `<blockquote><p>1</p><p>2</p></blockquote>` | defaults | `<blockquote dir="auto"><p>1</p><p dir="auto">2</p></blockquote>` |
| F02 | Nested same tag - text first | `<blockquote>text<p>1</p><p>2</p></blockquote>` | defaults | `<blockquote dir="auto">text<p dir="auto">1</p><p dir="auto">2</p></blockquote>` |
| F03 | Nested same tag - comment first | `<blockquote><!--c--><p>1</p><p>2</p></blockquote>` | defaults | `<blockquote dir="auto"><!--c--><p>1</p><p dir="auto">2</p></blockquote>` |
| F04 | Nested same tag - blank first | `<blockquote>\n<p>1</p><p>2</p></blockquote>` | defaults | `<blockquote dir="auto">\n<p>1</p><p dir="auto">2</p></blockquote>` |
| F05 | Deep nesting (single child chain) | `<div><div><div><p>x</p></div></div></div>` | defaults | Only outermost `<div dir="auto">`, inner divs and p skipped (each level has 1 child → always "first") |
| F06 | Mixed content order | `<div><p>1</p>text<p>2</p></div>` | defaults | `<div dir="auto"><p>1</p>text<p dir="auto">2</p></div>` |

### 3. List Special Handling

| ID | Name | Input | Config | Expected Output |
|----|------|-------|--------|-----------------|
| L01 | li not bidified | `<ul><li>Item<p>para</p></li></ul>` | defaults | `<ul dir="auto"><li>Item<p dir="auto">para</p></li></ul>` |
| L02 | li with leading paragraph | `<ul><li><p>First</p>Rest</li></ul>` | defaults | `<ul dir="auto"><li><p>First</p>Rest</li></ul>` |

### 4. Dir Attribute Boundaries

| ID | Name | Input | Config | Expected Output |
|----|------|-------|--------|-----------------|
| D01 | Non-greedy stops at dir | `<div><p>1</p><div dir="ltr"><p>2</p><p>3</p></div></div>` | defaults | `<div dir="auto"><p>1</p><div dir="ltr"><p>2</p><p>3</p></div></div>` |
| D02 | Greedy ignores dir | Same as D01 | `greedy: true` | `<div dir="auto"><p>1</p><div dir="auto"><p>2</p><p dir="auto">3</p></div></div>` |
| D03 | Dir on root child | `<div dir="rtl"><p>x</p></div>` | defaults | Unchanged (root child has dir) |
| D04 | Dir="auto" also stops | `<div dir="auto"><p>x</p></div>` | defaults | Unchanged |

### 5. Table Support

| ID | Name | Input | Config | Expected Output |
|----|------|-------|--------|-----------------|
| T01 | Table basic | `<table><tr><td>a</td><td>b</td></tr></table>` | `with_table_support: true` | `<table dir="auto"><tr><td>a</td><td dir="auto">b</td></tr></table>` |
| T02 | Table with thead/tbody | `<table><thead><tr><th>H</th></tr></thead><tbody><tr><td>D</td></tr></tbody></table>` | `with_table_support: true` | Table, thead get dir; first th, first td skipped |
| T03 | Table without option | `<table><tr><td>x</td></tr></table>` | defaults | Unchanged |

### 6. Configuration Options

| ID | Name | Input | Config | Expected Output |
|----|------|-------|--------|-----------------|
| C01 | including_tags adds | `<span>x</span>` | `including_tags: ['span']` | `<span dir="auto">x</span>` |
| C02 | excluding_tags removes | `<div>x</div>` | `excluding_tags: ['div']` | `<div>x</div>` |
| C03 | only_tags restricts | `<p>x</p><div>y</div>` | `only_tags: ['p']` | `<p dir="auto">x</p><div>y</div>` |
| C04 | excluding overrides including | `<xyz>x</xyz>` | `inc: ['xyz'], exc: ['xyz']` | `<xyz>x</xyz>` |
| C05 | only_tags ignores others | `<p>x</p><span>y</span>` | `only_tags: ['p'], inc: ['span']` | `<p dir="auto">x</p><span>y</span>` |
| C06 | with_table_support adds | `<table><tr><td>x</td></tr></table>` | `with_table_support: true` | Table tags bidified |

### 7. Multiple Roots

| ID | Name | Input | Config | Expected Output |
|----|------|-------|--------|-----------------|
| M01 | Sibling elements | `<p>1</p><div>2</div>` | defaults | `<p dir="auto">1</p><div dir="auto">2</div>` |
| M02 | Text + element | `text<div>x</div>` | defaults | `text<div dir="auto">x</div>` |

### 8. Attribute Preservation

| ID | Name | Input | Config | Expected Output |
|----|------|-------|--------|-----------------|
| A01 | Preserves class/id | `<p class="foo" id="bar">x</p>` | defaults | `<p class="foo" id="bar" dir="auto">x</p>` |
| A02 | Preserves order | `<p id="a" class="b">x</p>` | defaults | `<p id="a" class="b" dir="auto">x</p>` |
| A03 | Preserves data attrs | `<p data-x="1" data-y="2">x</p>` | defaults | All data attrs + dir |

### 9. Unicode/Bidi Content

| ID | Name | Input | Config | Expected Output |
|----|------|-------|--------|-----------------|
| U01 | RTL text | `<p>مرحبا</p>` | defaults | `<p dir="auto">مرحبا</p>` |
| U02 | Mixed RTL/LTR | `<p>hello مرحبا</p>` | defaults | `<p dir="auto">hello مرحبا</p>` |
| U03 | Bidi in tables | `<table><tr><td>راست left</td><td>left راست</td></tr></table>` | `with_table_support: true` | First td skipped, second gets dir |

### 10. Edge Cases

| ID | Name | Input | Config | Expected Output |
|----|------|-------|--------|-----------------|
| E01 | Empty element | `<p></p>` | defaults | `<p dir="auto"></p>` |
| E02 | Self-closing | `<br><hr>` | defaults | Unchanged (not bidifiable) |
| E03 | Script/style | `<script>x</script><style>x</style>` | defaults | Unchanged |
| E04 | Nested different tags | `<div><blockquote><p>x</p></blockquote></div>` | defaults | Both div and blockquote get dir |
| E05 | Case insensitive | `<DIV><P>x</P></DIV>` | defaults | `<DIV dir="auto"><P>x</P></DIV>` |

## Running Tests

For Ruby reference implementation:
```bash
bundle exec rspec spec/
```

For other implementations, create equivalent tests using the Input/Config/Expected columns above.

## Compliance Scoring

| Level | Requirements |
|-------|--------------|
| **Core** | Pass B01-B04, F01-F06, L01-L02 |
| **Standard** | Core + D01-D04, T01-T03, C01-C06 |
| **Full** | Standard + M01-M02, A01-A03, U01-U03, E01-E05 |

Minimum compliance: **Core level**