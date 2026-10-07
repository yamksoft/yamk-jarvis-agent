"""
Open Web content or 3D models directly in the central HUD view.
"""
from __future__ import annotations
from pathlib import Path

def hud_viewer(parameters: dict = None, response=None, player=None, session_memory=None) -> str:
    params = parameters or {}
    mode = params.get("mode")
    url_or_path = params.get("url_or_path") or ""
    title = params.get("title") or ""
    
    if not player:
        return "No display is available."
        
    target = player
    if not hasattr(target, "open_web_view") and hasattr(player, "_win"):
        target = player._win

    if mode == "web":
        if url_or_path.startswith("javascript:"):
            script = url_or_path[11:]
            if hasattr(target, "run_web_javascript"):
                target.run_web_javascript(script)
                return f"Executed JavaScript in the web view: {script}"
            return "JavaScript execution is not supported by the current UI."
            
        if not url_or_path.startswith("http") and not url_or_path.startswith("file"):
            url_or_path = "https://" + url_or_path
        if hasattr(target, "open_web_view"):
            target.open_web_view(url_or_path, title)
            return f"Opened {url_or_path} in the web view on the HUD."
        return "Web view is not supported by the current UI."
        
    elif mode == "3d":
        if url_or_path and not url_or_path.startswith("http") and not url_or_path.startswith("data:"):
            p = Path(url_or_path.strip("\"'")).expanduser()
            if p.exists():
                url_or_path = str(p.absolute())
            else:
                return f"Error: Local 3D model file not found at {p.absolute()}. You must download or create a valid .glb or .gltf file first before calling this tool!"
        if hasattr(target, "open_3d_view"):
            target.open_3d_view(url_or_path, title)
            return f"Opened 3D model {url_or_path} on the HUD."
        return "3D model view is not supported by the current UI."
        
    elif mode == "close_web":
        if hasattr(target, "close_web_view"):
            target.close_web_view()
            return "Closed web view."
    
    elif mode == "close_3d":
        if hasattr(target, "close_3d_view"):
            target.close_3d_view()
            return "Closed 3D view."
            
    return f"Unknown mode or missing parameters for hud_viewer: {mode}"


TOOL = {
    "name": "hud_viewer",
    "description": (
        "Opens embedded web content (like browsing a website) or 3D models directly in the assistant's central HUD display instead of a separate window. "
        "Use this when the user explicitly asks to view a website inside the app, open a web page on screen, or view a 3D model. "
        "Modes: 'web', '3d', 'close_web', 'close_3d'. "
        "For 'web', url_or_path is the website URL. "
        "For '3d', url_or_path is the file path to the 3D model. "
        "CRITICAL: If the user asks you to click a link or interact with a webpage that is ALREADY OPEN in the HUD, you MUST use this tool with mode='web' and url_or_path set to a javascript snippet (e.g. 'javascript:document.querySelector(\"a\").click();'). DO NOT use 'browser_control' for pages opened in the HUD!"
    ),
    "parameters": {
        "type": "OBJECT",
        "properties": {
            "mode": {
                "type": "STRING",
                "description": "'web' to open website, '3d' to open 3D model, 'close_web' to return to default face, 'close_3d' to close 3d model.",
                "enum": ["web", "3d", "close_web", "close_3d"]
            },
            "url_or_path": {
                "type": "STRING",
                "description": "The URL of the website or the file path of the 3D model."
            },
            "title": {
                "type": "STRING",
                "description": "Short title to display in the header (optional)."
            }
        },
        "required": ["mode"]
    },
    "handler": hud_viewer,
}
