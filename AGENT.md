# AGENT.md — Bidify-RB Project Instructions

## Project Overview
Ruby library for adding `dir="auto"` to HTML block elements based on the Unicode Bidirectional Algorithm. Core algorithm in `lib/bidify/bidifier.rb` (57 lines).

## Key Files
| File | Purpose |
|------|---------|
| `lib/bidify/bidifier.rb` | Core recursive algorithm |
| `lib/bidify/html_string_bidifier.rb` | Entry point (parse → recurse → serialize) |
| `spec/html_string_bidifier_spec.rb` | All test cases (35+) |
| `docs/ai-agent-guide.md` | **Read this first** — token-efficient reference |

## Commands
```bash
# Run tests
bundle exec rspec

# Manual test
ruby -e "require './lib/bidify'; puts Bidify.bidify_html_string('<div><p>a</p><p>b</p></div>')"
```

## Algorithm Summary
Post-order DFS. At each parent: track `seen_first` (reset per parent). For each child: skip if has `dir` (unless `greedy`); recurse; add `dir="auto"` if and only if `(is_root OR seen_first) AND tag ∈ bidifiable_tags`; then `seen_first = true` if element or non-blank text.

## Config Options
- `with_table_support`, `including_tags`, `excluding_tags`, `only_tags`, `greedy`
- Precedence: `only_tags` > `excluding_tags` > `including_tags` > `with_table_support` > defaults

## Critical Behaviors
- **First-content skip**: First actual content child of each parent never gets `dir="auto"`
- **Single-child chain**: Only root gets `dir="auto"` (each level resets `seen_first`)
- **Dir boundaries**: Existing `dir` attr stops recursion (unless `greedy: true`)
- **Fragment parsing**: No `<html>/<body>` wrapper

## Compliance
Run test matrix: `docs/reference/test-matrix.md`
Minimum: Core level (14 tests)
