Start-Process ollama serve -Environment @{ OLLAMA_MAX_VRAM = '42949672960' } -WindowStyle Hidden
Start-Process node "$PSScriptRoot\server.mjs" -WorkingDirectory $PSScriptRoot -WindowStyle Hidden