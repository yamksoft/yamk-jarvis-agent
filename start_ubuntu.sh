#!/bin/bash
set -e

echo "========================================================"
echo " Jarvis AI Assistant - Ubuntu Launcher"
echo "========================================================"
echo ""

cd "$(dirname "$0")"
SCRIPT_DIR="$(pwd)"

echo "Choose Jarvis Operating Mode:"
echo "[1] Local Mode (Starts Local LiveKit Server, Frontend, and Backend)"
echo "[2] Cloud Mode (Starts Frontend and Backend ONLY)"
echo ""
read -p "Enter your choice (1 or 2): " choice

if [ "$choice" = "1" ]; then
    echo -e "\e[32mStarting Local Mode...\e[0m"
    
    LIVEKIT_PATH="$SCRIPT_DIR/livekit-server-linux/livekit-server"
    if [ ! -f "$LIVEKIT_PATH" ]; then
        echo -e "\e[31mError: LiveKit Server not found. Please run setup_ubuntu.sh first to download it.\e[0m"
        exit 1
    fi

    echo -e "\e[33mLaunching LiveKit Server in the background...\e[0m"
    nohup "$LIVEKIT_PATH" --dev --bind 0.0.0.0 > "$SCRIPT_DIR/livekit.log" 2>&1 &
    echo $! > "$SCRIPT_DIR/.livekit.pid"
elif [ "$choice" = "2" ]; then
    echo -e "\e[32mStarting Cloud Mode...\e[0m"
else
    echo -e "\e[31mInvalid choice. Exiting...\e[0m"
    exit 1
fi

echo -e "\e[33mLaunching Frontend in the background...\e[0m"
cd "$SCRIPT_DIR/jarvis/frontend"
nohup npm run dev > "$SCRIPT_DIR/frontend.log" 2>&1 &
echo $! > "$SCRIPT_DIR/.frontend.pid"

echo -e "\e[33mLaunching Backend in the background...\e[0m"
cd "$SCRIPT_DIR/jarvis"
nohup uv run src/agent.py dev > "$SCRIPT_DIR/backend.log" 2>&1 &
echo $! > "$SCRIPT_DIR/.backend.pid"

echo ""
echo "========================================================"
echo -e "\e[32m All services have been launched in the background!\e[0m"
echo -e "\e[33m You can monitor logs by running:\e[0m"
echo " tail -f frontend.log backend.log"
echo ""
echo -e "\e[32m To stop the servers, run:\e[0m"
echo " ./stop_ubuntu.sh"
echo "========================================================"
