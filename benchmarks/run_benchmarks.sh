#!/bin/bash
# TurboServo Benchmark Suite
# Compares TurboServo vs Hono (Bun) vs Go net/http
# Requires: wrk (brew install wrk), bun, go, turbolang

set -e

DURATION=10       # seconds per test
THREADS=4
CONNECTIONS=100

echo "=== TurboServo Benchmark Suite ==="
echo "Duration: ${DURATION}s | Threads: ${THREADS} | Connections: ${CONNECTIONS}"
echo ""

# Check dependencies
command -v wrk >/dev/null 2>&1 || { echo "ERROR: wrk not found. Install with: brew install wrk"; exit 1; }
command -v bun >/dev/null 2>&1 || { echo "ERROR: bun not found."; exit 1; }
command -v go >/dev/null 2>&1 || { echo "ERROR: go not found."; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# ── TurboServo ────────────────────────────────────────────────────────
echo "--- Starting TurboServo (port 3000) ---"
turbolang run "$SCRIPT_DIR/api_bench.tb" &
TURBO_PID=$!
sleep 2

echo ""
echo "=== TurboServo: GET /json ==="
wrk -t$THREADS -c$CONNECTIONS -d${DURATION}s http://localhost:3000/json
echo ""
echo "=== TurboServo: GET /user?id=1 ==="
wrk -t$THREADS -c$CONNECTIONS -d${DURATION}s "http://localhost:3000/user?id=1"
echo ""

kill $TURBO_PID 2>/dev/null
wait $TURBO_PID 2>/dev/null
sleep 1

# ── Hono (Bun) ────────────────────────────────────────────────────────
echo "--- Starting Hono/Bun (port 3001) ---"
cd "$SCRIPT_DIR"
if [ ! -f node_modules/.package-lock.json ]; then
    bun add hono 2>/dev/null
fi
bun run hono_bench.ts &
HONO_PID=$!
sleep 2

echo ""
echo "=== Hono (Bun): GET /json ==="
wrk -t$THREADS -c$CONNECTIONS -d${DURATION}s http://localhost:3001/json
echo ""
echo "=== Hono (Bun): GET /user?id=1 ==="
wrk -t$THREADS -c$CONNECTIONS -d${DURATION}s "http://localhost:3001/user?id=1"
echo ""

kill $HONO_PID 2>/dev/null
wait $HONO_PID 2>/dev/null
sleep 1

# ── Go ────────────────────────────────────────────────────────────────
echo "--- Starting Go (port 3002) ---"
go run "$SCRIPT_DIR/go_bench.go" &
GO_PID=$!
sleep 2

echo ""
echo "=== Go net/http: GET /json ==="
wrk -t$THREADS -c$CONNECTIONS -d${DURATION}s http://localhost:3002/json
echo ""
echo "=== Go net/http: GET /user?id=1 ==="
wrk -t$THREADS -c$CONNECTIONS -d${DURATION}s "http://localhost:3002/user?id=1"
echo ""

kill $GO_PID 2>/dev/null
wait $GO_PID 2>/dev/null

echo ""
echo "=== Benchmark complete ==="
