# 05 - Configuration and Environment Variables

Jarvis dynamically loads its configuration based on the operating mode you select.

## Operating Modes

When you visit `http://localhost:3000/setup`, you can choose between two modes:

### Local Offline Mode
This mode is best for local development. It expects a LiveKit server to be running on your local machine (`localhost`). 
- Configuration is saved to `.env.local`
- The system automatically starts or connects to the local LiveKit server.

### Cloud Mode
This mode connects directly to LiveKit Cloud or a remote production server.
- Configuration is saved to `.env.cloud`
- The local LiveKit server is automatically killed to free up system resources.

## Environment Variables
The following environment variables are required and managed automatically by the setup UI:

- `LIVEKIT_URL`: The WebSocket URL of the LiveKit server (e.g., `ws://localhost:7880`).
- `LIVEKIT_API_KEY`: The API key to authenticate with LiveKit.
- `LIVEKIT_API_SECRET`: The API secret to authenticate with LiveKit.
- `GOOGLE_API_KEY`: Your Gemini API key used by the Python backend for the AI agent's brain.
- `JARVIS_MODE`: Specifies whether it's running in `local` or `cloud`.

## Hot Reloading
When you save the configuration in the UI, the frontend makes an API call to `/api/setup`. This API route performs the following magic:
1. It writes your new values to `.env.local` or `.env.cloud`.
2. It writes your chosen mode to `active_mode.txt`.
3. It kills the local LiveKit server if you switched to Cloud mode.
4. It touches the `agent.py` file, which triggers the Python `uv` watcher to **hot-reload** the backend instantly, forcing it to read the new `.env` file without requiring a manual restart!
