# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.13.1] - 2025-12-12

### Added
- Added Ruby 3.4 compatibility by including bundled gems as runtime dependencies:
  - `mutex_m` - required by mechanize for thread synchronization
  - `nkf` - Network Kanji Filter, required by mechanize for character encoding
  - `reline` - required by mechanize dependencies

### Fixed
- Fixed `LoadError` when using capybara-mechanize with Ruby 3.4+, where stdlib gems were extracted to bundled gems

## [1.13.0] - Previous Release

- (Previous changes not documented)
