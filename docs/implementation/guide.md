# Bidify Implementation Guide

> **Purpose**: This guide enables developers to implement the bidify algorithm in any programming language. It specifies the exact behavior, data structures, and test cases required for compliance.

---

## 1. Requirements

### 1.1 HTML Parser Capabilities

Your HTML parser MUST support:
- **Fragment parsing** (not full document parsing)
- **Tree traversal** (access to children, parent, siblings)
- **Node type detection**: element, text, comment
- **Attribute access**: get, set, check existence
- **Text content access**: including whitespace preservation
- **Serialization** back to HTML string

### 1.2 Required Node Properties

Each parsed node must expose:
| Property | Description |
|----------|-------------|
| `node_type` | `:element`, `:text`, `:comment`, etc. |
| `name` | Tag name (lowercase for elements) |
| `children` | Ordered array of child nodes |
| `attributes` | Map of attribute name → value |
| `text_content` | Raw text content (for text nodes) |
| `blank?` | True if text node contains only whitespace |

---

## 2. Data Structures

### 2.1 Configuration Object

```python
# Example in Python-like pseudocode
class BidifyConfig:
    with_table_support: bool = False
    including_tags: List[str] = []
    excluding_tags: List[str] = []
    only_tags: Optional[List[str]] = None
    greedy: bool = False
```

### 2.2 Internal State

```python
class BidifierState:
    config: BidifyConfig
    bidifiable_tags: Set[str]  # Computed from config
    
    def __init__(self, config):
        self.config = config
        self.bidifiable_tags = self._compute_bidifiable_tags()
    
    def _compute_bidifiable_tags(self) -> Set[str]:
        if self.config.only_tags is not None:
            return set(self.config.only_tags)
        
        tags = set(DEFAULT_TAGS)
        if self.config.with_table_support:
            tags.update(TABLE_TAGS)
        if self.config.including_tags:
            tags.update(self.config.including_tags)
        if self.config.excluding_tags:
            tags.difference_update(self.config.excluding_tags)
        return tags
```

### 2.3 Constants

```python
DEFAULT_TAGS = {
    'div', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6',
    'p', 'ul', 'ol', 'blockquote'
}

TABLE_TAGS = {
    'table', 'thead', 'tbody', 'th', 'tr', 'td'
}
```

---

## 3. Core Algorithm Implementation

### 3.1 Entry Point

```python
def bidify_html_string(html_string: str, config: BidifyConfig = None) -> str:
    config = config or BidifyConfig()
    state = BidifierState(config)
    fragment = parse_html_fragment(html_string)  # Returns root fragment node
    _bidify_recursively(fragment, state, is_root=True)
    return serialize_html(fragment)
```

### 3.2 Recursive Function

```python
def _bidify_recursively(node, state: BidifierState, is_root: bool = False):
    """
    Post-order depth-first traversal.
    Modifies node tree in-place by adding dir="auto" attributes.
    """
    seen_first_content = False
    
    for child in node.children:
        # Check recursion stop condition
        if _should_stop_recursion(child, state):
            continue
        
        # Recurse first (post-order)
        _bidify_recursively(child, state, is_root=False)
        
        # Apply dir="auto" if conditions met
        if (is_root or seen_first_content) and _is_bidifiable(child, state):
            _set_dir_auto(child)
        
        # Update first-content tracker
        if _is_actual_content(child):
            seen_first_content = True
```

### 3.3 Helper Functions

```python
def _should_stop_recursion(node, state: BidifierState) -> bool:
    """Return True if we should skip this node and its children."""
    if state.config.greedy:
        return False
    return node.has_attribute('dir')

def _is_actual_content(node) -> bool:
    """Return True if node counts as 'actual content' for first-content rule."""
    if node.node_type == 'element':
        return True
    if node.node_type == 'text':
        return not node.is_blank()  # Non-whitespace text
    return False  # Comments, PIs, etc.

def _is_bidifiable(node, state: BidifierState) -> bool:
    """Return True if this element should receive dir="auto"."""
    return node.node_type == 'element' and node.name.lower() in state.bidifiable_tags

def _set_dir_auto(node):
    """Set dir="auto" on element node."""
    node.set_attribute('dir', 'auto')
```

---

## 4. Required Test Cases

### 4.1 Basic Functionality

| Test | Input | Expected Output |
|------|-------|-----------------|
| Single paragraph | `<p>text</p>` | `<p dir="auto">text</p>` |
| All default tags | `<div>x</div><h1>x</h1>...` | All get `dir="auto"` |
| Non-bidifiable tags | `<span>x</span><img>` | Unchanged |

### 4.2 First-Content Rule

| Test | Input | Expected Output |
|------|-------|-----------------|
| Nested same tag | `<blockquote><p>1</p><p>2</p></blockquote>` | `<blockquote dir="auto"><p>1</p><p dir="auto">2</p></blockquote>` |
| Text first | `<blockquote>text<p>1</p><p>2</p></blockquote>` | `<blockquote dir="auto">text<p dir="auto">1</p><p dir="auto">2</p></blockquote>` |
| Comment first | `<blockquote><!--c--><p>1</p><p>2</p></blockquote>` | `<blockquote dir="auto"><!--c--><p>1</p><p dir="auto">2</p></blockquote>` |
| Blank first | `<blockquote>\n<p>1</p><p>2</p></blockquote>` | `<blockquote dir="auto">\n<p>1</p><p dir="auto">2</p></blockquote>` |

### 4.3 List Handling

| Test | Input | Expected Output |
|------|-------|-----------------|
| li not bidified | `<ul><li>x<p>y</p></li></ul>` | `<ul dir="auto"><li>x<p dir="auto">y</p></li></ul>` |

### 4.4 Dir Attribute Boundaries

| Test | Input | Expected Output |
|------|-------|-----------------|
| Non-greedy (default) | `<div><p>1</p><div dir="ltr"><p>2</p></div></div>` | `<div dir="auto"><p>1</p><div dir="ltr"><p>2</p></div></div>` |
| Greedy | Same input, `greedy=true` | `<div dir="auto"><p>1</p><div dir="auto"><p>2</p></div></div>` |

### 4.5 Table Support

| Test | Input | Expected Output |
|------|-------|-----------------|
| Table with option | `<table><tr><td>a</td><td>b</td></tr></table>` | `<table dir="auto"><tr><td>a</td><td dir="auto">b</td></tr></table>` |

### 4.6 Configuration Options

| Test | Config | Input | Expected |
|------|--------|-------|----------|
| including_tags | `['span']` | `<span>x</span>` | `<span dir="auto">x</span>` |
| excluding_tags | `['div']` | `<div>x</div>` | `<div>x</div>` |
| only_tags | `['p']` | `<p>x</p><div>y</div>` | `<p dir="auto">x</p><div>y</div>` |
| excluding overrides including | `inc=['xyz'], exc=['xyz']` | `<xyz>x</xyz>` | `<xyz>x</xyz>` |

### 4.7 Multiple Roots

| Test | Input | Expected Output |
|------|-------|-----------------|
| Sibling roots | `<p>1</p><div>2</div>` | `<p dir="auto">1</p><div dir="auto">2</div>` |

---

## 5. Compliance Checklist

An implementation is compliant if it passes ALL test cases in Section 4 AND:

- [ ] Uses post-order depth-first traversal
- [ ] Correctly computes effective bidifiable tags per precedence rules
- [ ] Implements first-content rule exactly (element OR non-blank text)
- [ ] Stops recursion at existing `dir` attribute (unless greedy)
- [ ] Preserves all original attributes and content
- [ ] Handles HTML fragments (multiple root nodes)
- [ ] Case-insensitive tag matching
- [ ] No external dependencies beyond HTML parser

---

## 6. Language-Specific Notes

### JavaScript/TypeScript
- Use `DOMParser` with `text/html` for fragment parsing
- `Node.nodeType`: 1=ELEMENT, 3=TEXT, 8=COMMENT
- `element.hasAttribute('dir')`, `element.setAttribute('dir', 'auto')`

### Python
- `lxml.html.fragment_fromstring()` or `html.parser.HTMLParser` subclass
- `lxml` preserves comments; `html.parser` may not by default

### Go
- `golang.org/x/net/html` for parsing
- `html.ParseFragment()` for fragment parsing
- Traverse using `FirstChild`/`NextSibling`

### Rust
- `html5ever` or `tl` crate for parsing
- Tree traversal via cursor or owned tree

### Java
- `Jsoup.parseBodyFragment()` for fragment parsing
- `Element.children()`, `Node.attributes()`

---

## 7. Performance Considerations

- **Time Complexity**: O(n) where n = number of nodes
- **Space Complexity**: O(d) where d = tree depth (recursion stack)
- **Optimization**: Single pass, in-place modification
- **Streaming**: Not possible (requires full tree for post-order)

---

## 8. Extension Points

For implementers wanting to extend:

1. **Custom node types**: Add handling for template elements, web components
2. **Content analysis**: Add actual bidi detection (current uses `dir="auto"`)
3. **Streaming API**: SAX-style parser for large documents
4. **CSS selector config**: Replace tag lists with selector engine

---

## 9. Version Compatibility

This guide corresponds to **bidify-rb v0.3.1** algorithm.

Future versions may add:
- New configuration options
- Additional default tags
- Modified first-content semantics (with major version bump)

Implementations should specify which version they comply with.