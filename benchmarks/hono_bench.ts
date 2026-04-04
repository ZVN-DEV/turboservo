// Hono benchmark — equivalent API to TurboServo benchmark
// Run: bun run benchmarks/hono_bench.ts

import { Hono } from "hono";

const app = new Hono();

interface User {
  id: number;
  name: string;
  email: string;
}

const users: Record<string, User> = {
  "1": { id: 1, name: "Alice", email: "alice@example.com" },
  "2": { id: 2, name: "Bob", email: "bob@example.com" },
};

// Endpoint 1: Simple JSON response
app.get("/json", (c) => c.json({ message: "Hello, World!" }));

// Endpoint 2: Echo posted JSON
app.post("/echo", async (c) => {
  const body = await c.req.json();
  return c.json(body);
});

// Endpoint 3: In-memory lookup
app.get("/user", (c) => {
  const id = c.req.query("id");
  const user = id ? users[id] : undefined;
  if (!user) return c.json({ error: "Not Found" }, 404);
  return c.json(user);
});

// Endpoint 4: Headers inspection
app.get("/headers", (c) => {
  return c.json({
    user_agent: c.req.header("user-agent") ?? "",
    accept: c.req.header("accept") ?? "",
  });
});

console.log("Hono benchmark server running on http://localhost:3001");
export default { port: 3001, fetch: app.fetch };
