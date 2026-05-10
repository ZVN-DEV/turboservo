# TurboServo audit against Turbo Lang 0.7.6

This project is now aligned to the latest shipped Turbo Lang release available at the time of this pass: **Turbo Lang 0.7.6** (released **April 13, 2026**).

## What changed in this repo

- Migrated TurboServo response helpers to Turbo 0.7.6's explicit HTTP helpers:
  - `respond_json`
  - `respond_text`
  - `respond_html`
- Added richer request helpers for:
  - typed integer query parsing
  - form-style body parsing
  - defaulted query lookup
- Upgraded the showcase from a raw endpoint list to a **real browser-facing demo server** with:
  - interactive dashboard at `/`
  - health endpoint at `/health`
  - metadata endpoint at `/api/info`
- Fixed concrete project bugs surfaced during audit:
  - `/search` now honors `page`, `limit`, `min_price`, and `max_price`
  - `/pipeline` now implements the documented `reduce:product`
  - router path matching now ignores query strings
- Added a smoke test that builds and exercises the live showcase server.
- Evolved the showcase into a stronger hosted-demo reference app with:
  - SSR landing page
  - live in-memory counters at `/api/server-state`
  - server-rendered status and memory fragments
  - a workload-comparison “compute arena” panel

## Gaps this project still exposes in Turbo Lang

These are repo-level observations intended to improve Turbo itself, not blockers for TurboServo:

1. **No first-class request body / form decoding helpers in stdlib**
   - We had to hand-roll form parsing for `key=value&...` payloads.
   - A built-in `request_form(req, key)` or `url_decode()` helper would reduce repeated parser code.

2. **No ergonomic JSON object/array builder for HTTP APIs**
   - Response payloads are still mostly hand-assembled strings.
   - A minimal stdlib JSON builder or serializer helpers for arrays/maps would improve correctness and readability.

3. **Routing still feels low-level**
   - TurboServo can register routes, but path-param ergonomics are still helper-driven instead of framework-integrated.
   - Native wildcard/path-param server routing would make real apps much cleaner.

4. **Redirects still need better primitives**
   - Turbo exposes response content-type helpers, but not an obvious first-class redirect/header API for framework authors.

5. **Real-world HTTP testing examples are still sparse**
   - The language ships `turbolang test`, but richer docs/examples around server integration tests would make real project adoption easier.

6. **Server-handler concurrency patterns need clearer documentation**
   - While building this hosted demo, the safest reliable path was to keep request-handler work synchronous and expose concurrency-style behavior through controlled server-owned state and workload comparisons.
   - Official examples/docs would help clarify which async or spawned patterns are intended to be stable inside HTTP handlers today.

## Recommended next Turbo Lang improvements

- Add standard URL/form decoding builtins
- Add header-setting / redirect response builtins
- Add small JSON composition helpers for arrays and maps
- Add native route params in the HTTP server API
- Publish an official "testing HTTP servers" example beside `web-dashboard`
- Publish an official “server-rendered HTML + fragments” reference app
- Document supported async/concurrency patterns for HTTP handlers explicitly
