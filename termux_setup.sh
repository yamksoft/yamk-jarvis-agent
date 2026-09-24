#!/bin/bash
echo "======================================"
echo "🚀 Setting up Jarvis Backend on Termux"
echo "======================================"

# 1. Update packages and install core requirements
echo "[1/4] Updating system and installing basic requirements..."
pkg update -y && pkg upgrade -y
pkg install -y python git clang make libffi openssl binutils

# 2. Download the project from GitHub
echo "[2/4] Downloading project from the official repository..."
cd ~
if [ -d "livekit-jarvis-server" ]; then
    echo "Project already exists, updating..."
    cd livekit-jarvis-server
    git pull
else
    git clone https://github.com/yamksoft/livekit-jarvis-server.git
    cd livekit-jarvis-server
fi

# 3. Enter the backend folder and set up environment
echo "[3/4] Setting up Python virtual environment..."
cd jarvis
python -m venv venv
source venv/bin/activate

# Upgrade installation tools
pip install --upgrade pip setuptools wheel

# --- ANDROID PATCH ---
# Playwright (Browser Tools) is not supported on Android. 
# We dynamically patch the code on Termux to run the Agent without the browser tools.
echo "Patching code to run on Android (removing Playwright dependency)..."
sed -i '/"playwright/d' pyproject.toml
sed -i '/from browser import BrowserManager/d' src/agent.py
sed -i '/from tools import BrowserTools/d' src/agent.py
sed -i '/show_browser = os.getenv/d' src/agent.py
sed -i '/self.browser = browser/d' src/agent.py
sed -i '/self.browser_tools = BrowserTools/d' src/agent.py
sed -i '/\*self.browser_tools.tools,/d' src/agent.py
sed -i '/browser = BrowserManager/d' src/agent.py
sed -i '/ctx.add_shutdown_callback(browser.close)/d' src/agent.py
sed -i 's/browser: BrowserManager | None = None//g' src/agent.py
sed -i 's/agent=Assistant(browser),/agent=Assistant(),/g' src/agent.py
# ----------------------

# 4. Install project packages
echo "[4/4] Installing dependencies (this may take a while on mobile)..."
pip install -e .

# Set up default environment file to connect to Windows
if [ ! -f ".env.local" ]; then
    echo "LIVEKIT_URL=ws://YOUR_WINDOWS_IP:7880" > .env.local
    echo "LIVEKIT_API_KEY=devkey" >> .env.local
    echo "LIVEKIT_API_SECRET=secret" >> .env.local
    echo "Created default .env.local - Make sure to edit the IP address later!"
fi

echo "======================================"
echo "✅ Installation completed successfully!"
echo "======================================"
echo "To run the backend at any time, open Termux and paste this command:"
echo ""
echo "cd ~/livekit-jarvis-server/jarvis && source venv/bin/activate && python src/agent.py dev"
echo "======================================"
