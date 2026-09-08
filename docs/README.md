# Bidify Documentation Index

This is the main entry point for the bidify algorithm documentation.

## Document Structure

```
docs/
├── README.md                 # This file
├── algorithm/
│   └── core-algorithm.md     # Core algorithm specification
├── configuration/
│   └── options.md            # All configuration options
├── edge-cases/
│   └── special-behaviors.md  # Edge cases and test-verified behaviors
├── implementation/
│   └── guide.md              # Language-agnostic implementation guide
└── reference/
    ├── quick-reference.md    # Quick lookup tables
    ├── test-matrix.md        # Complete test case matrix
    └── ai-summary.json       # Machine-readable specification
```

## Quick Navigation

### For Algorithm Understanding
→ [Core Algorithm](algorithm/core-algorithm.md) - The exact rules and pseudocode

### For Configuration
→ [Options Reference](configuration/options.md) - All options with examples

### For Edge Cases
→ [Special Behaviors](edge-cases/special-behaviors.md) - All tested edge cases

### For Implementation
→ [Implementation Guide](implementation/guide.md) - Complete guide for any language

### For Quick Lookup
→ [Quick Reference](reference/quick-reference.md) - Tables and cheat sheets

### For Testing
→ [Test Matrix](reference/test-matrix.md) - Complete test cases for compliance

### For AI/LLM Consumption
→ [AI Summary](reference/ai-summary.json) - Structured machine-readable spec

## Version

This documentation covers **bidify-rb v0.3.1** algorithm specification.

## Compliance

Any implementation claiming "bidify compliance" must:
1. Pass all test cases in [Test Matrix](reference/test-matrix.md)
2. Follow the algorithm in [Core Algorithm](algorithm/core-algorithm.md)
3. Support all options in [Options Reference](configuration/options.md)
4. Handle all edge cases in [Special Behaviors](edge-cases/special-behaviors.md)

## Related

- [bidify-rb GitHub](https://github.com/dobidi/bidify-rb) - Reference Ruby implementation
- [Unicode Bidirectional Algorithm](https://www.unicode.org/reports/tr9/) - Underlying bidi spec
- [HTML dir attribute](https://developer.mozilla.org/en-US/docs/Web/HTML/Global_attributes/dir) - MDN reference