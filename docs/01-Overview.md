# 01 - Overview and Architecture

Welcome to the Jarvis AI Assistant project! This is a real-time Voice AI assistant built with LiveKit.

## Architecture Components

The project consists of three main components that communicate with each other:

1. **Frontend (Next.js)**: 
   - Located in `jarvis/frontend`.
   - Provides the visual interface for users to talk to the AI.
   - Built with Next.js, React, and TailwindCSS.
   - Uses the `@livekit/components-react` library to connect to the LiveKit server.

2. **Backend (Python)**:
   - Located in `jarvis/src/agent.py`.
   - The "brain" of the AI. It listens to audio streams from the user, processes them using Large Language Models (LLMs), and sends audio responses back.
   - Built with the LiveKit Python Agents Framework.

3. **LiveKit Server (Go)**:
   - The central router. Both the Frontend (user) and Backend (AI) connect to this server via WebSockets/WebRTC.
   - It handles all the heavy lifting of routing audio and video streams between participants with extremely low latency.
   - **Important**: This is an officially maintained open-source server by LiveKit. Our project downloads the pre-compiled binary directly from their official GitHub releases. We do not compile it from source locally.

## Operating Modes

Jarvis supports two distinct modes of operation:

- **Local Mode**: Runs everything on your local machine. It starts a local instance of the LiveKit Server (`localhost:7880`) and connects the frontend and backend to it. This is best for completely private development.
- **Cloud Mode**: Connects to a managed LiveKit Cloud project (`wss://your-project.livekit.cloud`). It does not run a local LiveKit server. Best for production or when you want to deploy your agent publicly.
