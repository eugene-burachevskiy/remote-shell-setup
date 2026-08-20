---
name: jina-reader
description: >-
  Fetches web pages as LLM-friendly markdown via Jina Reader (r.jina.ai),
  including JavaScript-rendered SPAs that regular HTTP fetch cannot read.
  Use when WebFetch, curl, or other direct fetches fail, return empty/blocked
  content, hit bot challenges, or need rendered page text from JS-heavy sites.
  Also use for PDF/Office URL conversion and optional web search via s.jina.ai.
compatibility: >
  Requires network access to https://r.jina.ai (and optionally https://s.jina.ai).
  Works anonymously with rate limits; optional JINA_API_KEY raises quota.
metadata:
  homepage: https://github.com/jina-ai/reader
  api: https://r.jina.ai/docs
---

# Jina Reader (fetch fallback)

Convert any URL to clean markdown using [Jina Reader](https://github.com/jina-ai/reader). Prefer this **after** a normal fetch fails or returns unusable content (empty body, bot wall, login wall HTML, JS shell only).

## When to use

Use this skill when:

- Direct `WebFetch` / `curl` / `wget` fails (timeout, 403/429/5xx, CAPTCHA, Cloudflare)
- Response is mostly empty or a JS app shell (`<div id="root">` with no content)
- Target is an SPA that needs headless Chrome rendering
- URL is a PDF or Office doc that should become markdown
- You need search → page content in one step (`s.jina.ai`)

Do **not** use as the default first fetch for simple static pages — try a normal fetch first.

## Quick start

Prepend `https://r.jina.ai/` to the target URL:

```bash
curl -sS --max-time 60 \
  -H 'x-timeout: 30' \
  -H 'x-preset: agent' \
  "https://r.jina.ai/https://example.com/page"
```

JSON (structured fields: `title`, `url`, `content`, `warning`):

```bash
curl -sS --max-time 60 \
  -H 'Accept: application/json' \
  -H 'x-timeout: 30' \
  -H 'x-preset: agent' \
  "https://r.jina.ai/https://example.com/page"
```

Always URL-encode the target if it contains query strings or special characters, or use POST (below).

## Auth (optional)

Anonymous works. For higher rate limits / proxy features:

```bash
# If JINA_API_KEY is set in the environment:
curl -sS --max-time 60 \
  -H "Authorization: Bearer ${JINA_API_KEY}" \
  -H 'x-timeout: 30' \
  -H 'x-preset: agent' \
  "https://r.jina.ai/https://example.com/page"
```

Get a key at https://jina.ai/reader. Never invent or hardcode keys.

## Fallback workflow

1. Try normal fetch first.
2. On failure / unusable content → call Reader with `x-preset: agent`.
3. If still thin or wrong content, escalate headers in order:

| Step | Headers | Why |
|------|---------|-----|
| Fresh fetch | `x-no-cache: true` | Bypass stale/blocked cache |
| Force JS | `x-engine: browser` | Sites that need Chrome, not curl |
| Wait longer | `x-timeout: 30`–`60` | Slow SPAs / lazy content |
| Wait for DOM | `x-wait-for-selector: <css>` | Content appears after render |
| Target body | `x-target-selector: <css>` | Skip chrome; extract main node |
| Hosted proxy | `x-proxy: auto` (needs API key) | Anti-bot / geo blocks |

Example escalation:

```bash
curl -sS --max-time 90 \
  -H "Authorization: Bearer ${JINA_API_KEY}" \
  -H 'Accept: application/json' \
  -H 'x-no-cache: true' \
  -H 'x-engine: browser' \
  -H 'x-timeout: 45' \
  -H 'x-preset: agent' \
  "https://r.jina.ai/https://hard-site.example/docs"
```

## POST for hash routes / awkward URLs

Hash fragments (`#/route`) are not sent on GET. Use POST:

```bash
curl -sS --max-time 60 -X POST 'https://r.jina.ai/' \
  -H 'Accept: application/json' \
  -H 'x-timeout: 30' \
  -H 'x-engine: browser' \
  -d 'url=https://example.com/#/dashboard'
```

## Useful headers (cheat sheet)

| Header | Values / notes |
|--------|----------------|
| `x-preset` | `agent` (default for agents), `research`, `index`, `reader`, `spider` |
| `x-engine` | `auto` (default), `browser`, `curl` |
| `x-respond-with` | `markdown`, `html`, `text`, `frontmatter`, `screenshot`, `pageshot` |
| `x-timeout` | seconds, max 180 |
| `x-wait-for-selector` | CSS selector to wait for |
| `x-target-selector` | CSS selector to extract |
| `x-remove-selector` | CSS to strip (e.g. `nav, footer, .ads`) |
| `x-no-cache` | `true` to bypass cache |
| `x-with-iframe` | `true` / `quoted` — include iframe content |
| `x-with-shadow-dom` | `true` — include shadow DOM text |
| `x-retain-images` | `all` / `none` / `alt` |
| `x-retain-links` | `all` / `none` / `text` |
| `x-max-tokens` | trim output to N tokens |

Prefer `x-preset: agent` unless you need a different pipeline shape.

## Search (`s.jina.ai`)

Search the web and get markdown for top results:

```bash
curl -sS --max-time 90 \
  -H 'Accept: application/json' \
  "https://s.jina.ai/$(python3 -c 'import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1]))' 'your search query')"
```

Site-restricted:

```bash
curl -sS --max-time 90 \
  'https://s.jina.ai/When%20was%20Jina%20AI%20founded%3F?site=jina.ai'
```

## PDFs and Office docs

Remote URL (any `.pdf` / Office link):

```bash
curl -sS --max-time 120 \
  -H 'Accept: application/json' \
  "https://r.jina.ai/https://example.com/report.pdf"
```

Local upload:

```bash
curl -sS --max-time 120 -X POST 'https://r.jina.ai/' \
  -F 'file=@./report.pdf' \
  -H 'Accept: application/json'
```

## Interpreting results

- Plain text responses start with `Title:` / `URL Source:` then markdown.
- JSON: use `data.content` (and `data.title`, `data.url`). Check `data.warning` for cache/partial notes.
- If content looks like a bot challenge or cookie wall, escalate with `x-engine: browser`, `x-no-cache: true`, then `x-proxy: auto` (with key).
- If still blocked after escalation, stop and report the URL + headers tried — do not loop endlessly.

## Rules

1. Try direct fetch first; use Reader as fallback (unless the user asks for Reader explicitly).
2. Always set a client `--max-time` and usually `x-timeout` so requests cannot hang forever.
3. Prefer `x-preset: agent` for agent browsing tasks.
4. Do not send secrets, cookies, or private authenticated app URLs unless the user explicitly requests it.
5. Prefer HTTPS target URLs. Quote/encode URLs properly in the shell.
6. Summarize or cite from the returned markdown; do not dump huge pages into the user reply unless asked.
