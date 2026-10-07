"""
Action to download files directly from the internet.
"""
import urllib.request
from pathlib import Path

def downloader(parameters: dict = None, response=None, player=None, session_memory=None) -> str:
    params = parameters or {}
    url = params.get("url")
    filename = params.get("filename")
    
    if not url or not filename:
        return "Error: 'url' and 'filename' are both required."
        
    try:
        p = Path(filename).expanduser().resolve()
        
        # Auto-fix common Github non-raw links
        if "github.com" in url and "/blob/" in url:
            url = url.replace("https://github.com/", "https://raw.githubusercontent.com/").replace("/blob/", "/")
        if "?raw=true" in url:
            url = url.replace("?raw=true", "")
            
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req) as response, open(p, 'wb') as out_file:
            out_file.write(response.read())
            
        # Verify if we accidentally downloaded an HTML page instead of a raw model
        if p.suffix.lower() == ".glb":
            with open(p, 'rb') as f:
                header = f.read(4)
                if header != b'glTF':
                    p.unlink(missing_ok=True)
                    return f"Error: Download failed. The URL returned a webpage (HTML) instead of the raw .glb binary file. Tell the user you couldn't find a direct link, or try a different source."
                    
        return f"Successfully downloaded file to {p.absolute()}"
    except Exception as e:
        return f"Error downloading file: {e}"

TOOL = {
    "name": "downloader",
    "description": (
        "Downloads a file directly from a given URL to the local filesystem. "
        "Use this when the user asks you to download something, or when you need "
        "to fetch a file (like a 3D .glb model) from the internet to use it later."
    ),
    "parameters": {
        "type": "OBJECT",
        "properties": {
            "url": {
                "type": "STRING",
                "description": "The direct URL of the file to download."
            },
            "filename": {
                "type": "STRING",
                "description": "The local filename or path to save it to (e.g. 'earth.glb')."
            }
        },
        "required": ["url", "filename"]
    },
    "handler": downloader,
}
