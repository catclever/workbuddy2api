# workbuddy2api (Generic Cloud Sidecar Image)

A pre-packaged, stateless Docker image for [`hawklithm/workbuddy2api`](https://github.com/hawklithm/workbuddy2api) (`codebuddy_proxy`) designed for cloud sidecar deployments (e.g., Railway, Fly.io, Dockge).

- **Zero Baked-in Credentials**: The image contains no session files or private tokens.
- **Env-to-Session Materialization**: Automatically materializes `/root/.codebuddy-global-session.json` from `SESSION_JSON` or `SESSION_B64` environment variables on startup.
- **Role Normalization Patch**: Automatically normalizes `developer` role messages to `system` and ensures a default `system` prompt exists for upstream compatibility.

## Usage in Railway (Sidecar Mode)

1. Create a new service in your Railway project:
   - **Option A (Pre-built GHCR Image)**: `+ New` -> `Docker Image` -> `ghcr.io/catclever/workbuddy2api:latest`
   - **Option B (GitHub Repo)**: `+ New` -> `GitHub Repo` -> `catclever/workbuddy2api`
2. Set service name to `workbuddy2api`.
3. Add Environment Variables (**Variables** tab):
   ```env
   PORT=48787
   WORKBUDDY_GLOBAL=true
   WORKBUDDY_DESENSITIZE=true
   SESSION_JSON={"auth":{...},"account":{...},"backend":"global","endpoint":"https://www.codebuddy.ai"}
   ```
   *(Or use `SESSION_B64` with base64-encoded content of `~/.codebuddy-global-session.json`)*
4. Connect from other services in the same Railway project via Private Networking:
   ```env
   LLM_BASE_URL=http://workbuddy2api.railway.internal:48787/v1
   LLM_MODEL=deepseek-v4.1-flash
   LLM_API_KEY=dummy
   ```
