# Appendix A: MCP Server Setup Guide

## MCP (Model Context Protocol) Installation Guide for Claude Code

This guide covers MCP server installation and configuration for Claude Code environments.

### Prerequisites

1. Node.js v18+ installed and in PATH
2. Identify your environment (Windows/Linux/macOS, WSL/PowerShell/CMD)

### Installation Process

#### 1. Basic Installation with mcp-installer

```bash
# Install MCP server using mcp-installer (user scope)
mcp-installer install [server-name]
```

#### 2. Verify Installation

```bash
# List installed MCPs
claude mcp list

# Test in debug mode
claude --debug

# Verify MCP availability (within 2 minutes)
echo "/mcp" | claude --debug
```

#### 3. Manual Configuration (if needed)

**User scope configuration example**:
```bash
claude mcp add --scope user youtube-mcp \
  -e YOUTUBE_API_KEY=$YOUR_YT_API_KEY \
  -e YOUTUBE_TRANSCRIPT_LANG=ko \
  -- npx -y youtube-data-mcp-server
```

### Configuration File Locations

**Linux/macOS/WSL**:
- User config: `~/.claude/`
- Project config: `[project-root]/.claude`

**Windows Native**:
- User config: `C:\Users\{username}\.claude`
- Project config: `[project-root]\.claude`

### JSON Configuration Examples

#### NPX Usage
```json
{
  "youtube-mcp": {
    "type": "stdio",
    "command": "npx",
    "args": ["-y", "youtube-data-mcp-server"],
    "env": {
      "YOUTUBE_API_KEY": "YOUR_API_KEY_HERE",
      "YOUTUBE_TRANSCRIPT_LANG": "ko"
    }
  }
}
```

#### Windows CMD Wrapper
```json
{
  "mcpServers": {
    "mcp-installer": {
      "command": "cmd.exe",
      "args": ["/c", "npx", "-y", "@anaisbetts/mcp-installer"],
      "type": "stdio"
    }
  }
}
```

#### PowerShell Example
```json
{
  "command": "powershell.exe",
  "args": [
    "-NoLogo", "-NoProfile",
    "-Command", "npx -y @anaisbetts/mcp-installer"
  ]
}
```

### Troubleshooting

#### If npm/npx not found:
```bash
# Check npm global install path
npm config get prefix
```

#### If uvx not found:
```bash
# Install uv (Python package manager)
curl -LsSf https://astral.sh/uv/install.sh | sh
```

### Important Notes

- Always use `-y` flag with npx to avoid version conflicts
- For Windows, JSON paths require double backslashes: `\\`
- Set `MCP_TIMEOUT` environment variable for slower systems
- API keys should use placeholder values initially, update with real keys later

### Server Removal

```bash
claude mcp remove [server-name]
```

### Common MCP Servers

- **context7**: Documentation and patterns
- **sequential**: Complex analysis
- **magic**: UI components
- **playwright**: Browser automation

For specific server documentation, check their official repositories.

---

**Related**: Return to [CLAUDE.md](../CLAUDE.md)