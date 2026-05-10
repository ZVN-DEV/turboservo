# TurboServo audit against Turbo Lang 0.8.2

This project is now aligned to the latest shipped Turbo Lang release available at the time of this pass: **Turbo Lang 0.8.2** (released **May 2026**).

## What changed in this repo (v0.8.2 upgrade)

- Added `create_public()` for binding to `0.0.0.0` (all interfaces), complementing the existing `create()` which binds to `127.0.0.1`.
- Added a CORS preflight helper. CORS headers are no longer emitted automatically by the Turbo runtime (removed in 0.8.2 as a secure-by-default change), so TurboServo now provides an explicit opt-in helper for handlers that need it.
- Added `patch()` and `options()` HTTP method helpers to the router, rounding out the standard method set alongside `get()`, `post()`, `put()`, and `delete()`.
- Added `respond_401()`, `respond_403()`, and `respond_405()` response helpers for auth and method-enforcement flows.
- Adopted `+=` compound assignment across the showcase, replacing `x = x + 1` patterns now that compound assignment is stable in the LLVM backend.
- Added `%20` and `%25` entries to the `url_decode` helper to cover space and literal percent signs in query strings.

## What Turbo Lang 0.8.x added that TurboServo benefits from

### Memory and runtime safety (0.8.0 – 0.8.1)

- **Arena-aware free** — the runtime now tracks arena ownership before freeing, eliminating a class of double-free and stale-pointer bugs that could surface under concurrent request load.
- **`turbo_strdup`** — internal string duplication now uses a length-bounded copy with overflow guards, replacing unbounded `strcpy` paths.
- **`read_fd_to_string` realloc fix** — the prior realloc path had an off-by-one on buffer growth; fixed in 0.8.0. Any TurboServo path that reads request bodies from a file descriptor inherits this fix.
- **Bounded copies throughout stdlib** — `strncat`, `snprintf`-style limits applied to runtime internals.

### HTTP-level hardening (0.8.1)

- **Header limits enforced at runtime**: 8 KB per header line, 64 KB total header block, 32 MB request body. Oversized requests are rejected before handler code runs. TurboServo does not need to reimplement these checks.
- **Content-Type injection prevention** — the runtime strips `\r` and `\n` from Content-Type values before they reach the wire.
- **Shell injection closed** — `exec` and `shell_exec` builtins now escape arguments; TurboServo handlers that invoke subprocess utilities are no longer responsible for manual escaping.

### Security defaults (0.8.2)

- **CORS removed by default** — the runtime no longer adds `Access-Control-Allow-Origin: *` automatically. This is a breaking change from 0.7.x but the correct default. TurboServo exposes an explicit CORS preflight helper for handlers that need cross-origin access.

### New stdlib primitives (0.8.0, not yet adopted in framework layer)

- **`try_read_file` / `try_write_file`** — safe file I/O that returns a result type instead of panicking on failure. Available for use in handler code; TurboServo's own framework files have not yet migrated from direct file calls.
- **`hashmap_set_int` / `hashmap_get_int`** — integer-typed hashmap accessors. Useful for in-process counters and caches; not yet surfaced as a TurboServo API.

### Compiler and language (0.8.1)

- **`if-let`, optional chaining, struct destructuring** — now working in the LLVM backend. Showcase code can use these idioms without falling back to C-backend workarounds.

## Gaps this project still exposes in Turbo Lang

These are repo-level observations intended to improve Turbo itself, not blockers for TurboServo:

1. **No first-class request body / form decoding helpers in stdlib**
   - Form parsing for `key=value&...` payloads is still hand-rolled.
   - A built-in `request_form(req, key)` or `url_decode()` stdlib helper would eliminate repeated parser code across projects.

2. **No ergonomic JSON object/array builder for HTTP APIs**
   - Response payloads are still mostly hand-assembled strings.
   - A minimal stdlib JSON builder or serializer helpers for arrays and maps would improve correctness and reduce surface area for malformed output.

3. **Routing still feels low-level**
   - Path-param ergonomics are still helper-driven rather than framework-integrated.
   - Native wildcard and path-param server routing at the stdlib level would make real apps significantly cleaner.

4. **Redirects still need better primitives**
   - Turbo exposes response content-type helpers but not a first-class redirect or arbitrary-header API for framework authors.

5. **Server-handler concurrency patterns need clearer documentation**
   - The safest reliable path remains synchronous request handlers with server-owned state for anything concurrency-adjacent.
   - Official documentation clarifying which async or spawned patterns are stable inside HTTP handlers would reduce guesswork for framework and app authors.

## Recommended next Turbo Lang improvements

- Add standard URL/form decoding builtins (`url_decode`, `request_form`)
- Add header-setting and redirect response builtins for framework use
- Add small JSON composition helpers for arrays and maps
- Add native route params in the HTTP server API
- Adopt `try_read_file` / `try_write_file` in stdlib HTTP examples to model the safe I/O pattern
- Publish an official "testing HTTP servers" example alongside `web-dashboard`
- Document supported async/concurrency patterns for HTTP handlers explicitly
