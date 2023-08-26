# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.3.1] - 2023-08-26
### Security
- Upgrade `nokogiry` for security issues with libxml2 dependency (#14)

## [0.3.0] - 2023-07-30

### Added
- Added a feature to stop budification if an element already has dir attribute
  and a `greedy` option to force bidification on all nested elements (#10)
- Added options for `only_tags`, `including_tags`, and `excluding_tags` (#12)

## [0.2.0] - 2023-07-02

### Changed
- BREAKING: change the interface (#8)

### Added
- Added `with_table_support` option (#9)

## [0.1.1] - 2023-06-25

### Added
- Include `div` in the default bidifiable tags (#6)

### Fixed
- Fix issues with lists by stoping bidification on `li` tags (#4)

## [0.1.0] - 2023-06-22

The initial release with the core functionality (#1)

[unreleased]: https://github.com/dobidi/bidify-rb/compare/v0.3.1...HEAD
[0.3.1]: https://github.com/dobidi/bidify-rb/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/dobidi/bidify-rb/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/dobidi/bidify-rb/compare/v0.1.1...v0.2.0
[0.1.1]: https://github.com/dobidi/bidify-rb/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/dobidi/bidify-rb/releases/tag/v0.1.0
