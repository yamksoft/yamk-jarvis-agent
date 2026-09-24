#!/bin/bash

cd "$(dirname "$0")"
SCRIPT_DIR="$(pwd)"

echo "Stopping Jarvis services..."

if [ -f "$SCRIPT_DIR/.frontend.pid" ]; then
    PID=$(cat "$SCRIPT_DIR/.frontend.pid")
    echo "Stopping Frontend (PID $PID)..."
    kill $PID 2>/dev/null || true
    rm "$SCRIPT_DIR/.frontend.pid"
fi

if [ -f "$SCRIPT_DIR/.backend.pid" ]; then
    PID=$(cat "$SCRIPT_DIR/.backend.pid")
    echo "Stopping Backend (PID $PID)..."
    kill $PID 2>/dev/null || true
    rm "$SCRIPT_DIR/.backend.pid"
fi

if [ -f "$SCRIPT_DIR/.livekit.pid" ]; then
    PID=$(cat "$SCRIPT_DIR/.livekit.pid")
    echo "Stopping LiveKit Server (PID $PID)..."
    kill $PID 2>/dev/null || true
    rm "$SCRIPT_DIR/.livekit.pid"
fi

echo "All services stopped."
