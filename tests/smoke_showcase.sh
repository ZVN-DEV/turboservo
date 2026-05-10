#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BIN="$(mktemp /tmp/turboservo-showcase.XXXXXX)"
LOG="$(mktemp /tmp/turboservo-showcase-log.XXXXXX)"

cleanup() {
  if [[ -n "${SERVER_PID:-}" ]]; then
    kill "${SERVER_PID}" 2>/dev/null || true
    wait "${SERVER_PID}" 2>/dev/null || true
  fi
  rm -f "$BIN" "$LOG"
}
trap cleanup EXIT

cd "$ROOT"
turbolang build examples/showcase/main.tb -o "$BIN" >/dev/null
PORT=3101 "$BIN" >"$LOG" 2>&1 &
SERVER_PID=$!
sleep 2

python3 - <<'PY'
import json
import urllib.request

def get_text(url, data=None):
    if data is not None:
        data = data.encode()
    req = urllib.request.Request(url, data=data)
    return urllib.request.urlopen(req, timeout=5).read().decode()

base = "http://127.0.0.1:3101"

health = json.loads(get_text(base + "/health"))
assert health["status"] == "ok"
assert health["version"] == "0.7.6"

info = json.loads(get_text(base + "/api/info"))
assert info["project"] == "TurboServo"
assert "/search" in info["routes"]
assert "/fragment/arena" in info["routes"]
assert "/fragment/status" in info["routes"]

server_state = json.loads(get_text(base + "/api/server-state"))
assert "total_requests" in server_state
assert "last_winner" in server_state

search = json.loads(get_text(
    base + "/search",
    "query=premium&category=electronics&page=2&limit=5&min_price=50&max_price=300",
))
assert search["page"] == 2
assert search["limit"] == 5
assert search["total_matches"] >= 0
assert len(search["results"]) <= 5

pipeline = json.loads(get_text(
    base + "/pipeline",
    "1,2,2,3,4\nunique\nmap:square\nreduce:product",
))
assert pipeline["reduced_value"] == 576

matrix = json.loads(get_text(base + "/matrix?size=12&op=trace"))
assert matrix["operation"] == "trace"
assert matrix["size"] == 12

status_fragment = get_text(base + "/fragment/status")
assert "Live status" in status_fragment
assert "Total requests" in status_fragment

memory_fragment = get_text(base + "/fragment/memory")
assert "Server memory board" in memory_fragment
assert "Arena runs" in memory_fragment

arena_fragment = get_text(base + "/fragment/arena", "")
assert "Compute Arena" in arena_fragment
assert "winner=" in arena_fragment

html = get_text(base + "/")
assert "A real TurboLang website where the server is the interactive engine." in html
assert "Reactive fragments" in html
assert "Compute Arena" in html
PY
