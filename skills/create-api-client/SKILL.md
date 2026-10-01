---
name: create-api-client
description: Generate a simple async Python API client from an OpenAPI/Swagger spec URL, using aiohttp for transport and Pydantic for response models, with no HTTP leakage.
---

# Create API Client

Build a small, simple async Python client for a web API described by an
OpenAPI/Swagger spec, given the spec's URL as `$ARGUMENTS`.

If `$ARGUMENTS` is empty, ask the user for the spec URL before doing anything
else.

## Design contract (non-negotiable)

- **One `Client` class.** No base classes per tag, no per-resource sub-clients,
  no plugin/middleware system. One method per operation.
- **`aiohttp` for transport, async only.** The `Client` is an async context
  manager (`__aenter__`/`__aexit__`) that opens and closes a single
  `aiohttp.ClientSession`. No sync wrapper.
- **`Client` is initialized with a `Config` object** — a Pydantic `BaseModel`
  holding `base_url`, whatever auth field(s) the spec's security scheme
  requires, and a timeout. Nothing else reads env vars or files implicitly.
- **Responses are Pydantic domain models**, one per schema component actually
  used in a response, named after the schema. Never return raw dicts or
  `aiohttp` response objects to the caller.
- **Zero leakage of the HTTP nature of the client.** This includes exceptions:
  callers must never need to catch `aiohttp.*` or know status codes are
  involved unless they choose to inspect them on your own exception types.
  Define a small exception hierarchy (base error, an API error carrying
  status/title/detail, a connection error for network/timeout failures) and
  translate every `aiohttp.ClientError` / `asyncio.TimeoutError` into one of
  these before it reaches the caller.
- **Keep it simple.** No retries, caching, rate limiting, or codegen
  machinery unless the user asks. Don't build an abstraction for a single
  usage.

## Steps

1. **Fetch the spec.** Try `curl -s <url>` first (fast, works for raw
   `swagger.json`/`openapi.json`). If the URL is an HTML docs page instead of
   raw JSON/YAML, look for the actual spec link on the page (commonly at
   `/swagger/.../swagger.json`, `/openapi.json`, `/v3/api-docs`, etc.) and
   fetch that instead. Read the full spec before writing any code.

2. **Survey the target project** before creating files:
   - Package manager and layout (`uv`, `poetry`, `pip`+`requirements.txt`,
     `src/` layout vs flat) — follow what's already there.
   - Whether a previously-generated client for the same API already exists
     in the environment (e.g. an installed package matching the spec's
     `info.title`) — it's a useful cross-reference for endpoint shapes and
     auth header conventions, but do not reuse its (likely sync,
     codegen-boilerplate) code or structure.

3. **Extract from the spec:**
   - `servers[0].url` → `Config.base_url` default.
   - `components.securitySchemes` → what auth field(s) `Config` needs and how
     the client attaches them (header name, query param, bearer prefix, etc).
     Match the scheme exactly — e.g. an `apiKey`-in-header scheme is a raw
     header value, not a `Bearer <token>` unless the spec says so.
   - `paths` → one client method per operation, named from `operationId`
     (snake_cased) or a sensible name derived from the path/verb if
     `operationId` is absent. Preserve the spec's grouping (`tags`) only as
     ordering/comments, not as separate classes.
   - `components.schemas` → one Pydantic model per schema used in a request
     or response body. Map the API's field naming convention (often
     camelCase) to idiomatic snake_case via `Field(alias=...)` +
     `ConfigDict(populate_by_name=True)`. Turn `enum` schemas into Python
     `Enum` (usually `str, Enum`) classes. Respect `required` vs nullable/
     optional fields (`X | None = None`).
   - Error response schemas (e.g. a `ProblemDetails`-style body) → the fields
     your API error exception surfaces (status code, title, detail).

4. **Generate the package**, following the project's existing layout
   conventions, named after the API (e.g. an "A-maze-ing API" →
   `amazeing_client`):
   - `config.py` — the `Config` model.
   - `exceptions.py` — the exception hierarchy described above.
   - `models.py` — the Pydantic domain models and enums.
   - `client.py` — the single `Client` class: `__aenter__`/`__aexit__`
     managing the `aiohttp.ClientSession` (base URL, auth header/params,
     timeout), one public async method per operation, and private
     `_request`/error-translation helpers.
   - `__init__.py` — re-export `Client`, `Config`, the exception types, and
     the domain models as the public API.

5. **Add dependencies** (`aiohttp`, `pydantic`) using the project's package
   manager (e.g. `uv add aiohttp pydantic`) rather than hand-editing lock
   files.

6. **Verify before reporting done:**
   - The package imports cleanly.
   - Each Pydantic model parses a spec-shaped example payload correctly
     (build one from the schema's `required`/`properties` and check aliasing
     round-trips).
   - If the spec's server is actually reachable, do a live smoke call
     (an intentionally invalid auth value is fine) and confirm failures
     surface as your own exception type with no `aiohttp` type or traceback
     frame leaking to the caller — not just that it "looks right".
   - Report type-checker findings on the new files if a type checker is
     configured, but don't treat editor/pyright environment-mismatch noise
     (e.g. a stale `VIRTUAL_ENV` warning) as a real failure — confirm with a
     direct run (`uv run python -c "import ..."`) before concluding an
     import error is real.

## Non-goals

Don't add a sync facade, a CLI, retry/backoff, response caching, or
per-endpoint pagination helpers unless the user explicitly asks — those are
scope the user didn't request, and this skill optimizes for the smallest
client that fully and correctly covers the spec.
