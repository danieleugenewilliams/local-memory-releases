# Local Memory - Binary Releases

This repository contains only the binary releases for Local Memory MCP Server. For source code, documentation, and development, see the main repository.

## Quick Installation

### NPM Package (Recommended)
```bash
npm install -g local-memory-mcp
local-memory --help
```

### Direct Download
Download the binary for your platform from the [Releases page](https://github.com/danieleugenewilliams/local-memory-releases/releases/latest):

- **macOS Intel**: `local-memory-macos-intel`
- **macOS Apple Silicon**: `local-memory-macos-arm` 
- **Linux (x64)**: `local-memory-linux`
- **Windows (x64)**: `local-memory-windows.exe`
- **Universal Package**: `local-memory-universal.zip` (all platforms)

## Platform Instructions

### macOS/Linux
```bash
# Download and make executable
curl -L -o local-memory https://github.com/danieleugenewilliams/local-memory-releases/releases/latest/download/local-memory-macos-arm
chmod +x local-memory
./local-memory --help
```

### Windows
1. Download `local-memory-windows.exe`
2. Run in Command Prompt: `local-memory-windows.exe --help`

## Getting Started
1. Get your license key from [localmemory.co](https://localmemory.co)
2. Activate: `local-memory license activate LM-XXXX-XXXX-XXXX-XXXX-XXXX`
3. Start the server: `local-memory start`
4. Install for Claude Desktop: `local-memory install mcp`

## Support
- **Documentation**: [localmemory.co/docs](https://localmemory.co/docs)
- **Support**: [localmemory.co/support](https://localmemory.co/support)
- **License**: Commercial - see [localmemory.co/terms](https://localmemory.co/terms)

---

**Note**: This repository contains only binary releases. No source code or development happens here. All releases are generated from the main private repository using a local build system (no GitHub Actions).