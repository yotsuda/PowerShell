# Copilot Instructions

## PowerShell MCP Tools — Use Instead of Bash

This repository provides **PowerShell.MCP** tools via MCP server. These tools provide a **persistent PowerShell session** that the built-in `bash` tool cannot replicate.

### Why You MUST Use PowerShell MCP Tools

The `bash` tool creates a **new process for every command**. This means:
- Variables are lost between calls
- Imported modules are lost between calls
- Working directory resets between calls
- Build environment state is lost between calls

The `invoke_expression` MCP tool maintains a **persistent PowerShell session** where:
- Variables persist across calls
- `Import-Module ./build.psm1` stays loaded — `Start-PSBuild` and `Start-PSPester` work without re-importing
- Working directory and environment variables persist
- Authentication and session state are maintained

### Rules

- **ALWAYS use `invoke_expression`** for PowerShell commands — NEVER use `bash` with `pwsh -Command`
- **NEVER use `dotnet build`** — use `Start-PSBuild` via `invoke_expression`
- **NEVER use `Invoke-Pester`** — use `Start-PSPester` via `invoke_expression`

### Available MCP Tools

| Tool | Purpose |
|---|---|
| `invoke_expression` | Execute PowerShell commands in persistent session |
| `get_current_location` | Get current working directory and available drives |
| `start_powershell_console` | Start the PowerShell console |
| `wait_for_completion` | Wait for long-running commands to complete |
| `generate_agent_id` | Generate unique agent ID for session isolation |

### Example Workflow

```
1. invoke_expression: Import-Module ./build.psm1
2. invoke_expression: Start-PSBootstrap -Scenario DotNet
3. invoke_expression: Start-PSBuild -Clean -PSModuleRestore -UseNuGetOrg
4. invoke_expression: & (Get-PSOutput) -Command '$PSVersionTable'
5. invoke_expression: Start-PSPester -Path <test-file> -UseNuGetOrg
```

All commands share the same session — modules and variables from step 1 are available in step 5.