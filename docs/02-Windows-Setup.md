# 02 - Windows Setup Guide

Running the Jarvis AI Assistant natively on Windows is fully supported and automated through PowerShell scripts.

## Prerequisites
- A modern Windows 10/11 operating system.
- An internet connection.
- That's it! The script will install everything else for you.

## Step 1: Initial Setup
Open the folder containing the project and double-click the file named **`setup_windows.cmd`** (or right-click `setup_windows.ps1` and choose "Run with PowerShell").

**What this script does:**
1. Requests Administrator privileges (needed to install system dependencies).
2. Uses the Windows Package Manager (`winget`) to install:
   - Git
   - Python 3.11
   - Node.js
3. Installs `uv` (a fast Python package installer).
4. Installs the Python backend dependencies and Playwright browsers.
5. Installs the Node.js frontend dependencies.
6. Downloads the official `livekit-server` executable for Windows directly from the official LiveKit GitHub releases. The executable is saved in a folder named `livekit-server-win` next to the script.

## Step 2: Running the Project
Once setup is complete, double-click **`start_jarvis.cmd`**.

A command prompt will ask you to choose a mode:
- **[1] Local Mode**: Starts the local LiveKit server, the Python backend, and the Next.js frontend in separate windows.
- **[2] Cloud Mode**: Starts only the Backend and Frontend (assuming you are connecting to LiveKit Cloud).

Your default web browser will automatically open to `http://localhost:3000`.

## Step 3: First-time Configuration
If this is your first time running the project, the frontend will automatically redirect you to the Setup page (`/setup`). 

1. Choose your desired mode (Local or Cloud).
2. Enter the required API keys (like your Gemini API key).
3. Click "Save & Apply".
4. The backend will automatically hot-reload and connect with your new settings!

## Stopping the Servers
Because the services run natively in separate command windows, you can stop them at any time simply by closing the black command prompt windows that opened.
