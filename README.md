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

## Features (v0.0.1)

- HTTP server with route registration (GET, POST, PUT, DELETE)
- Request context: method, path, headers, query params, body
- JSON/text/HTML response helpers
- Path parameter extraction via router module
- Benchmark suite vs Hono (Bun) and Go

## API

### Server (`src/servo.tb`)
- `create(port: i64) -> i64` — create server on port
- `get(app, path, handler)` — register GET route
- `post(app, path, handler)` — register POST route
- `put(app, path, handler)` — register PUT route  
- `delete(app, path, handler)` — register DELETE route
- `listen(app)` — start server (blocks)

### Request (`src/request.tb`)
- `method(req) -> str` — HTTP method
- `path(req) -> str` — request path
- `body(req) -> str` — request body
- `query(req, key) -> str` — query parameter
- `header(req, name) -> str` — request header

### Response (`src/response.tb`)
- `json(status, body) -> str` — JSON response
- `text(status, body) -> str` — text response
- `not_found() -> str` — 404 response
- `bad_request(msg) -> str` — 400 response

### Router (`src/router.tb`)
- `match_path(pattern, path) -> str` — match with params
- `param(params, key) -> str` — extract named param

## Benchmarks

```bash
./benchmarks/run_benchmarks.sh
```

Compares identical JSON API workloads across TurboServo, Hono/Bun, and Go net/http.
