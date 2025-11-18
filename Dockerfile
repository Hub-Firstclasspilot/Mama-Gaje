FROM oven/bun:1-alpine

WORKDIR /app

# Copy all static files
COPY . .

# Create Bun server script
RUN echo 'import { serve } from "bun"; \
import { join, extname } from "path"; \
\
const dist = "."; \
const cacheControl = { \
  ".html": "no-cache", \
  ".js": "public, max-age=31536000, immutable", \
  ".css": "public, max-age=31536000, immutable", \
  ".png": "public, max-age=31536000, immutable", \
  ".jpg": "public, max-age=31536000, immutable", \
  ".svg": "public, max-age=31536000, immutable", \
  ".webp": "public, max-age=31536000, immutable", \
  ".ico": "public, max-age=31536000, immutable", \
}; \
\
serve({ \
  port: 3000, \
  hostname: "0.0.0.0", \
  async fetch(req) { \
    const url = new URL(req.url); \
    let filePath = join(dist, url.pathname === "/" ? "index.html" : url.pathname); \
    let ext = extname(filePath); \
\
    try { \
      const file = Bun.file(filePath); \
      if (!(await file.exists())) { \
        filePath = join(dist, "index.html"); \
        ext = ".html"; \
      } \
\
      const shouldCompress = [".html", ".js", ".css", ".json", ".svg"].includes(ext); \
      let body = await file.arrayBuffer(); \
\
      const headers = new Headers({ \
        "Content-Type": file.type, \
        "Cache-Control": cacheControl[ext] || "public, max-age=3600", \
      }); \
\
      if (shouldCompress && req.headers.get("Accept-Encoding")?.includes("gzip")) { \
        body = Bun.gzipSync(Buffer.from(body)); \
        headers.set("Content-Encoding", "gzip"); \
      } \
\
      return new Response(body, { headers }); \
    } catch (error) { \
      console.error("Error serving file:", error); \
      return new Response("Not found", { status: 404 }); \
    } \
  }, \
}); \
\
console.log("🚀 Bun server running at http://0.0.0.0:3000");' > server.js

EXPOSE 3000
CMD ["bun", "server.js"]