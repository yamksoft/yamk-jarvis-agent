#!/bin/bash
set -e

echo "========================================================"
echo " Jarvis AI Assistant - Ubuntu Automated Setup Script"
echo "========================================================"
echo ""

# Move to script directory
cd "$(dirname "$0")"
SCRIPT_DIR="$(pwd)"

echo "Updating package lists..."
sudo apt-get update

echo "Installing system dependencies..."
sudo apt-get install -y curl git python3 python3-pip python3-venv wget unzip jq

# Install Node.js if not installed
if ! command -v node &> /dev/null; then
    echo "Installing Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt-get install -y nodejs
else
    echo "Node.js is already installed."
fi

# Clone repository if we are not inside one
if [ ! -f "$SCRIPT_DIR/jarvis/src/agent.py" ]; then
    echo "Repository not found in current directory. Cloning from GitHub..."
    git clone https://github.com/yamksoft/yamk-jarvis-agent.git
    cd livekit-jarvis-server
    SCRIPT_DIR="$(pwd)"
else
    echo "Repository files found."
fi

# Install uv (Python Package Manager)
if ! command -v uv &> /dev/null; then
    echo "Installing 'uv' Python package manager..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.local/bin:$PATH"
else
    echo "uv is already installed."
fi

# Setup Backend
echo "Setting up Python Backend..."
cd "$SCRIPT_DIR/jarvis"
uv sync
echo "Installing Playwright browsers..."
uv run playwright install chromium
uv run playwright install-deps chromium

# Setup Frontend
echo "Setting up Next.js Frontend..."
cd "$SCRIPT_DIR/jarvis/frontend"
npm install
cd "$SCRIPT_DIR"

# Download LiveKit Server for Linux
echo "Downloading latest LiveKit Server for Linux..."
LIVEKIT_API="https://api.github.com/repos/livekit/livekit/releases/latest"
DOWNLOAD_URL=$(curl -s $LIVEKIT_API | jq -r '.assets[] | select(.name | contains("linux_amd64.tar.gz")) | .browser_download_url')

if [ -n "$DOWNLOAD_URL" ]; then
    TAR_PATH="$SCRIPT_DIR/livekit-server.tar.gz"
    EXTRACT_PATH="$SCRIPT_DIR/livekit-server-linux"
    
    if [ ! -f "$EXTRACT_PATH/livekit-server" ]; then
        echo "Downloading LiveKit Server..."
        curl -L $DOWNLOAD_URL -o "$TAR_PATH"
        echo "Extracting LiveKit Server..."
        mkdir -p "$EXTRACT_PATH"
        tar -xzf "$TAR_PATH" -C "$EXTRACT_PATH"
        rm "$TAR_PATH"
        echo "LiveKit Server installed successfully in $EXTRACT_PATH."
    else
        echo "LiveKit Server is already installed."
    fi
else
    echo "Error finding LiveKit Linux release."
fi

echo ""
echo "========================================================"
echo " Setup Complete! Everything is ready."
echo " You can now run './start_ubuntu.sh' to launch."
echo "========================================================"
