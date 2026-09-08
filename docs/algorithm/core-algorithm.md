# Core Bidification Algorithm

This document specifies the exact algorithm for adding `dir="auto"` to HTML elements to enable proper bidirectional text rendering. Any implementation claiming compliance must follow these rules precisely.

## Overview

The algorithm performs a **depth-first, post-order traversal** of the HTML tree, applying `dir="auto"` to qualifying elements based on their position relative to sibling content.

## Default Bidifiable Tags

These tags receive `dir="auto"` by default:

```
Block-level:  div, h1, h2, h3, h4, h5, h6, p, blockquote
List:         ul, ol
```

## Table Tags (Opt-in)

When `with_table_support` is enabled:

```
table, thead, tbody, th, tr, td
```

## Key Concept: "First Content Element" Rule

**Critical Rule**: Within any parent container, the **first child that constitutes "actual content"** does NOT receive `dir="auto"`. All subsequent bidifiable siblings DO receive it.

### Definition of "Actual Content"

A node qualifies as "actual content" if:
- It is an **element node** (any tag), OR
- It is a **text node** with non-whitespace content (not blank)

Nodes that do NOT count as actual content:
- Blank text nodes (whitespace only)
- HTML comments
- Processing instructions

## Algorithm Pseudocode

```
function bidify(node, options):
    seen_first_content = false
    
    for each child in node.children:
        if should_stop_recursion(child, options):
            continue
        
        bidify(child, options)  // Recurse first (post-order)
        
        if (is_root OR seen_first_content) AND is_bidifiable(child, options):
            set_attribute(child, "dir", "auto")
        
        if is_actual_content(child):
            seen_first_content = true

function should_stop_recursion(node, options):
    if options.greedy == true:
        return false
    return node.has_attribute("dir")

function is_actual_content(node):
    return node.is_element() OR (node.is_text() AND not node.is_blank())

function is_bidifiable(node, options):
    return bidifiable_tags.contains(node.name)
```

## Traversal Order

1. **Post-order** (children before parent) - ensures nested elements are processed first
2. **Depth-first** - complete each branch before moving to next sibling
3. **Left-to-right** - siblings processed in document order

## Root Element Handling

The root fragment node is treated specially:
- `is_root = true` for the initial call
- This means the **first actual content child of the root** is skipped, but the root itself is never bidified (it's a document fragment)

## Attribute Application

When an element qualifies:
- Set `dir="auto"` (overwrites any existing value unless stopped by recursion rule)
- Do NOT modify other attributes
- Do NOT modify element content