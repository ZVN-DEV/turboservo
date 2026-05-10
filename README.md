# TurboServo

A lightweight HTTP server framework for the [Turbo](https://turbolang.dev) programming language.

## Quick Start

```turbo
import { create, get, post, listen } from "./src/servo"
import { json, text } from "./src/response"
import { body, query } from "./src/request"

fn main() {
    let app = create(3000)

    get(app, "/", |req: str| -> str {
        text(200, "Hello from TurboServo!")
    })

    get(app, "/greet", |req: str| -> str {
        let name = query(req, "name")
        json(200, "{\"hello\": \"" + name + "\"}")
    })

    post(app, "/echo", |req: str| -> str {
        json(200, body(req))
    })

    print("Server running on http://localhost:3000")
    listen(app)
}
```

```bash
turbolang run examples/hello/main.tb
```

## Features (v0.7.6)

- HTTP server with route registration (GET, POST, PUT, DELETE)
- Request context: method, path, headers, query params, body
- Explicit JSON/text/HTML response helpers aligned to Turbo Lang 0.7.6
- Typed query/form parsing helpers for real request handling
- Path parameter extraction via router module
- Browser-facing hosted demo with live in-memory state
- Server-rendered HTML fragments for live status panels
- Real JSON workload endpoints for compute-heavy interactions
- Benchmark suite vs Hono (Bun) and Go

## API

### Server (`src/servo.tb`)
- `create(port: i64) -> i64` -- create server on port
- `get(app, path, handler)` -- register GET route
- `post(app, path, handler)` -- register POST route
- `put(app, path, handler)` -- register PUT route
- `delete(app, path, handler)` -- register DELETE route
- `listen(app)` -- start server (blocks)

### Request (`src/request.tb`)
- `method(req) -> str` -- HTTP method
- `path(req) -> str` -- request path
- `body(req) -> str` -- request body
- `query(req, key) -> str` -- query parameter
- `header(req, name) -> str` -- request header
- `query_or(req, key, fallback) -> str` -- query parameter with default
- `query_i64(req, key, fallback) -> i64` -- typed integer query parameter
- `form_value(body, key) -> str` -- parse `application/x-www-form-urlencoded` style bodies
- `form_i64(body, key, fallback) -> i64` -- typed integer form field

### Response (`src/response.tb`)
- `json(status, body) -> str` -- JSON response
- `text(status, body) -> str` -- text response
- `html(status, body) -> str` -- HTML response
- `created_json(body) -> str` -- 201 JSON response
- `accepted_json(body) -> str` -- 202 JSON response
- `no_content() -> str` -- 204 empty response
- `not_found() -> str` -- 404 response
- `bad_request(msg) -> str` -- 400 response

### Router (`src/router.tb`)
- `match_path(pattern, path) -> str` -- match with params
- `param(params, key) -> str` -- extract named param

## Performance Showcase

The showcase server demonstrates Turbo's native computation speed through five endpoints that process real data workloads. These are the endpoints we benchmark against Go and Bun.

### Running the showcase

```bash
turbolang run examples/showcase/main.tb
```

All example servers respect `PORT` when set, so you can avoid local port collisions:

```bash
PORT=3101 turbolang run examples/showcase/main.tb
```

The server starts on port 3001 with:

- `GET /` -- hosted-demo style landing page
- `GET /health` -- server readiness payload
- `GET /api/info` -- project metadata
- `GET /api/server-state` -- live in-memory counters
- `GET /fragment/status` -- server-rendered live status panel
- `GET /fragment/memory` -- server-rendered memory board
- `POST /fragment/arena` -- server-owned workload comparison fragment
- `POST /transform`
- `POST /analyze`
- `POST /search`
- `GET /matrix`
- `POST /pipeline`

What the hosted demo now proves:

- Turbo can serve a real landing page directly as HTML
- the server can own live state in memory without a database
- the browser can ask Turbo for fresh HTML fragments for live panels
- heavy compute endpoints can remain JSON APIs while the page stays SSR-first

Open the dashboard in your browser:

```bash
open http://localhost:3001/
```

### POST /transform -- Data Transformation Pipeline

Multi-stage processing of CSV records: parse, validate, normalize, aggregate, sort, paginate.

```bash
curl -X POST http://localhost:3001/transform -d '1,Alice,500,engineering
2,Bob,300,marketing
3,Carol,450,engineering
4,Dave,200,sales
5,Eve,600,engineering'
```

Returns sorted records, category totals, and aggregate statistics.

### POST /analyze -- Statistical Analysis

Computes practical statistics on numerical data: mean, median, stddev, variance, percentiles (p50/p95/p99), histogram (10 bins), and outlier detection.

```bash
curl -X POST http://localhost:3001/analyze -d '1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20'
```

### POST /search -- Full-Text Search

Fuzzy text search across 1000 in-memory product records with relevance scoring, category filtering, and pagination.

```bash
# Search all categories
curl -X POST http://localhost:3001/search -d 'query=premium'

# Filter by category + price range + pagination
curl -X POST http://localhost:3001/search -d 'query=gadget&category=electronics&page=2&limit=5&min_price=50&max_price=300'
```

### GET /matrix -- Matrix Computation

Matrix operations using tight nested loops. Supports multiply, transpose, and trace.

```bash
# 10x10 matrix multiply (returns full result)
curl 'http://localhost:3001/matrix?size=10&op=multiply'

# 100x100 matrix multiply (returns metadata + trace)
curl 'http://localhost:3001/matrix?size=100&op=multiply'

# Transpose
curl 'http://localhost:3001/matrix?size=10&op=transpose'

# Trace
curl 'http://localhost:3001/matrix?size=10&op=trace'
```

### POST /pipeline -- Chained Data Processing

Configurable multi-stage pipeline with stage-by-stage tracking. Stages: filter, map, sort, reduce, unique, reverse, take.

```bash
curl -X POST http://localhost:3001/pipeline -d '1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20
filter:even
map:double
sort:desc
reduce:sum'
```

Available pipeline stages:
- `filter:even` / `filter:odd` -- filter by parity
- `filter:gt:N` / `filter:lt:N` -- filter by threshold
- `map:double` / `map:square` / `map:negate` / `map:add:N` -- transform values
- `sort:asc` / `sort:desc` -- sort order
- `reduce:sum` / `reduce:product` / `reduce:min` / `reduce:max` -- aggregate to single value
- `unique` -- remove duplicates
- `reverse` -- reverse array
- `take:N` -- keep first N elements

## Audit notes

This repo now carries `TURBO-LANG-AUDIT.md`, which documents:

- the Turbo Lang release this project was aligned to
- the concrete bugs fixed during the upgrade
- gaps this real project still exposes in Turbo itself

That file is intended to make TurboServo a living feedback project for Turbo Lang, not just a demo.

## Hosted demo architecture

TurboServo is now shaped like a realistic deployed reference app:

- SSR landing page from a single Turbo binary
- live server-memory counters exposed as HTML fragments + JSON
- progressive enhancement with tiny browser JavaScript
- compute APIs (`/analyze`, `/search`, `/matrix`, `/pipeline`) still directly callable

For public hosting, keep following Turbo's current guidance:

- run the Turbo binary behind **nginx** or **Caddy**
- do not expose the built-in HTTP server directly to untrusted networks

## Benchmarks

```bash
./benchmarks/run_benchmarks.sh
```

Compares identical JSON API workloads across TurboServo, Hono/Bun, and Go net/http.

## Project Structure

```
turboservo/
  src/
    servo.tb              # Core server API
    request.tb            # Request helpers
    response.tb           # Response builders
    router.tb             # Path parameter extraction
    showcase/
      transform.tb        # /transform endpoint
      analyze.tb          # /analyze endpoint
      search.tb           # /search endpoint
      matrix.tb           # /matrix endpoint
      pipeline.tb         # /pipeline endpoint
  examples/
    hello/main.tb         # Simple hello world
    showcase/main.tb      # Performance showcase server
  benchmarks/
    api_bench.tb          # TurboServo benchmark server
    go_bench.go           # Go comparison
    hono_bench.ts         # Bun/Hono comparison
    run_benchmarks.sh     # Benchmark runner
  turbo.toml
  README.md
```
