# 04 - Docker Setup Guide

If you prefer to run the project using containerization, we provide a complete Docker Compose configuration. This is the recommended approach for production deployments on Linux servers.

## Prerequisites
- Docker installed (`sudo apt install docker.io` on Linux, or Docker Desktop on Windows/Mac).
- Docker Compose installed.

## Does Docker use local LiveKit source code?
**No.** A common misconception is that building the Docker image copies a local version of the LiveKit server. 

If you look at the `docker-compose.yml` file, you will see:
```yaml
  livekit-server:
    image: livekit/livekit-server:latest
```
This tells Docker to completely ignore local files for the LiveKit server, and instead pull the official, pre-compiled `latest` image directly from LiveKit's official Docker Hub repository. This ensures you are always running the most stable and up-to-date server without needing to compile it yourself.

## Building and Running

1. Open a terminal in the root of the repository (where `docker-compose.yml` is located).
2. Run the following command:
```bash
docker compose up --build -d
```
3. Docker will download the LiveKit image, build the `jarvis-app` image (containing both the Python backend and Next.js frontend), and start them in the background (`-d`).

## Accessing the App
Once running, you can access the frontend at `http://localhost:3005`.

## Viewing Logs
To see the logs of the running containers:
```bash
docker compose logs -f
```

## Stopping Docker
To safely stop the containers and remove the network:
```bash
docker compose down
```

## Docker Networking Rules (URLs)
When running the stack inside Docker Desktop, URL configuration depends on whether the component connecting to LiveKit is *inside* or *outside* the Docker network.

- **Backend / Frontend Server (`livekit-server`)**: Services running inside Docker (like the Python agent or Next.js server) must connect to LiveKit using the internal Docker hostname: `ws://livekit-server:7880` or `http://livekit-server:7880`.
- **Client / Browser / Flutter App (`localhost`)**: Any client running on the host OS (outside Docker) must connect using the host network address: `ws://localhost:7880` or `ws://127.0.0.1:7880`.

