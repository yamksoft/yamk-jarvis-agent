# 03 - Ubuntu Setup Guide

We provide automated bash scripts to quickly set up and run the Jarvis AI Assistant on Ubuntu or other Debian-based Linux distributions. 

This guide is designed for beginners. You do not need to install anything manually; the script will handle it all.

## Step 1: Clone the Repository
If you haven't already, clone this repository to your Ubuntu machine and navigate into it:
```bash
git clone https://github.com/yamksoft/yamk-jarvis-agent.git
cd livekit-jarvis-server
```
*(Note: You can actually run the setup script directly on a fresh Ubuntu machine by creating `setup_ubuntu.sh` and it will automatically clone the repo for you if it's missing!)*

## Step 2: Make Scripts Executable
Before you can run the scripts, you must give them execution permissions:
```bash
chmod +x setup_ubuntu.sh start_ubuntu.sh stop_ubuntu.sh
```

## Step 3: Run the Setup Script
Execute the setup script. It will ask for your `sudo` password to install system packages.
```bash
./setup_ubuntu.sh
```

**What this script does:**
1. Installs `curl`, `git`, `python3`, `npm`, and `nodejs` via `apt`.
2. Installs `uv` (a fast Python package manager).
3. Installs backend dependencies and Playwright browsers.
4. Installs frontend dependencies (`npm install`).
5. Downloads the official `livekit-server` for Linux (`linux_amd64.tar.gz`) directly from the official LiveKit GitHub releases and extracts it into the `livekit-server-linux` folder.

## Step 4: Start the Servers
Once setup completes, launch the servers using the start script:
```bash
./start_ubuntu.sh
```
You will be prompted to choose an operating mode:
- **[1] Local Mode**: Starts LiveKit Server, Backend, and Frontend.
- **[2] Cloud Mode**: Starts Backend and Frontend only.

The services will run in the **background** using `nohup`. This means they will keep running even if you close your terminal session.

## Step 5: Viewing Logs
Because the services run in the background, their output is saved to log files. You can watch the live logs at any time by running:
```bash
tail -f frontend.log backend.log livekit.log
```
Press `Ctrl+C` to stop viewing the logs (the servers will continue running).

## Step 6: Stopping the Servers
When you are done developing, you can easily stop all background processes by running:
```bash
./stop_ubuntu.sh
```
This script finds the Process IDs (PIDs) of the servers and safely shuts them down.
