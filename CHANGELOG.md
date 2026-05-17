# Changelog

## [0.1.0-beta.1-wip]

### Added

- Initial release.
- `tracedZitadel<T>(...)` — wraps a otel_zitadel call in a CLIENT-kind span
  with vendor-specific attributes.
- Zone-scoped suppression via `runWithoutZitadelInstrumentation()` / `Async()`.
