#requires -Version 7.6
# Safe compatibility entrypoint. MCP configuration is project-scoped; this script
# NEVER modifies Claude/Codex user-global MCP settings.
Set-StrictMode -Version Latest
Write-Host 'Project MCP configuration (no Firebase cloud MCP):' -ForegroundColor Cyan
Write-Host '  VS Code: .vscode/mcp.json'
Write-Host '  Claude Code: .mcp.json'
Write-Host '  Codex: .codex/config.toml (requires project trust)'
Write-Host 'If a server is configured but not connected, authorize the provider in the client.'
Write-Host 'Do not register Firebase MCP on Contributor machines.'
exit 0
