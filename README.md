# Local Memory - Binary Distribution

**Version 1.4.1** - Ready-to-run binaries for macOS, Linux, and Windows.

Local Memory is an AI-powered persistent memory system with vector search, semantic analysis, and intelligent categorization through the Model Context Protocol (MCP). It works with Claude Code, Claude Desktop, Gemini, Codex, Cursor, and other MCP-compatible tools.

## Download

| Platform | Download |
|----------|----------|
| **macOS (Apple Silicon)** | [local-memory-macos-arm](https://github.com/danieleugenewilliams/local-memory-releases/releases/latest/download/local-memory-macos-arm) |
| **macOS (Intel)** | [local-memory-macos-intel](https://github.com/danieleugenewilliams/local-memory-releases/releases/latest/download/local-memory-macos-intel) |
| **macOS (Universal)** | [local-memory-universal.zip](https://github.com/danieleugenewilliams/local-memory-releases/releases/latest/download/local-memory-universal.zip) |
| **Linux (x64)** | [local-memory-linux](https://github.com/danieleugenewilliams/local-memory-releases/releases/latest/download/local-memory-linux) |
| **Windows (x64)** | [local-memory-windows.exe](https://github.com/danieleugenewilliams/local-memory-releases/releases/latest/download/local-memory-windows.exe) |

## Quick Start

```bash
# 1. Make executable (macOS/Linux)
chmod +x ./local-memory-*

# 2. Activate license
./local-memory license activate LM-XXXX-XXXX-XXXX-XXXX-XXXX

# 3. Start the service
./local-memory start

# 4. Store and search memories
./local-memory remember "Important project notes"
./local-memory search "project notes"
```

### Claude Desktop Integration

Add to your `claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "local-memory": {
      "command": "/full/path/to/local-memory",
      "args": ["--mcp"]
    }
  }
}
```

Use the full path to your downloaded binary.

### Platform Notes

**macOS**: First run may show a security warning. Go to System Preferences > Security & Privacy > Allow anyway, or run: `xattr -d com.apple.quarantine ./local-memory-*`

**Windows**: May show SmartScreen warning. Click "More info" then "Run anyway".

**Linux**: Ensure executable permissions with `chmod +x ./local-memory-linux`.

## What's New in v1.4.1

- **Multi-Provider AI Backend** - Mix and match AI providers for embeddings and chat: Ollama (local, default), OpenAI, Anthropic (Claude), claude CLI, and OpenAI-compatible servers (LM Studio, vLLM, LocalAI). Fallback chains and circuit breakers for resilience.
- **Agent Attribution** - Track which agent and machine stored each memory with automatic detection
- **Default Domain** - Organize memories by project with intelligent domain detection from agent config files
- **Security Hardening** - API key redaction, SSRF protection, command injection prevention, secure file permissions

## Also Available Via NPM

```bash
npm install -g local-memory-mcp
```

The npm package handles binary download and PATH setup automatically.

## Support

- **Documentation**: [localmemory.co/docs](https://localmemory.co/docs)
- **Discord**: [Local Memory Discord](https://discord.gg/rMmn8xP3fZ)
- **Issues**: [GitHub Issues](https://github.com/danieleugenewilliams/local-memory-releases/issues)
- **License**: [localmemory.co/terms](https://localmemory.co/terms)

---

**Download the latest release and start building persistent AI memory in minutes.**
