# AGENTS.md - Issue Fix Workflow for AI Coding Agents

This document provides step-by-step instructions for AI coding agents (Claude Code, Copilot, etc.) to fix issues in the PowerShell repository using PowerShell.MCP.

## Prerequisites

- PowerShell.MCP module is installed and available via MCP
- The repository is cloned and ready to work with

## Workflow Overview

1. Understand the issue
2. Reproduce the issue (using system pwsh, before building)
3. Clone and build PowerShell
4. Fix the code
5. Rebuild and verify the fix
6. Run tests
7. Submit PR

## Critical Rules

- **NEVER use `dotnet build` directly** — always use `Start-PSBuild`
- **NEVER use `Invoke-Pester` directly** — always use `Start-PSPester`
- **NEVER reference issue numbers in source code**

---

## Step 1: Understand the Issue

- Read the issue description and comments carefully
- Identify the affected module, cmdlet, or component
- Search the codebase to locate relevant source files

## Step 2: Reproduce the Issue

**Before cloning or building**, reproduce the reported issue using the system-installed pwsh. This saves a build cycle.

1. Write a minimal script that demonstrates the bug
2. Execute it and confirm the incorrect behavior matches the issue description
3. Document the reproduction result (expected vs actual)

This confirms:
- The issue is reproducible
- You understand the exact failure condition
- You have a concrete test to verify the fix later

> **Note**: If the issue requires source-level changes to reproduce (e.g., internal API behavior), skip this step and reproduce after building in Step 5.

## Step 3: Clone and Build PowerShell

```powershell
git clone https://github.com/PowerShell/PowerShell.git
cd PowerShell
Import-Module ./build.psm1
Start-PSBootstrap -Scenario DotNet
Start-PSBuild -Clean -PSModuleRestore -UseNuGetOrg
```

Verify the build succeeded and record version info:

```powershell
$pwshPath = Get-PSOutput
Write-Host "Built pwsh: $pwshPath"
& $pwshPath -Command '$PSVersionTable'
```

**Include the `$PSVersionTable` output in the PR description** to prove the build succeeded.

## Step 4: Fix the Code

- Modify the relevant source files to fix the issue
- Follow the coding standards defined in CLAUDE.md
- Key rules:
  - Never reference issue numbers in source code
  - Use `is null` / `is not null` instead of `== null` / `!= null`
  - Enable `#nullable enable` near the top of modified files
  - Follow existing code style and .editorconfig

## Step 5: Rebuild and Verify

Rebuild with the fix:

```powershell
Import-Module ./build.psm1
Start-PSBuild -UseNuGetOrg
```

Then switch to the built pwsh and verify:

```powershell
# Get the built pwsh path
$pwshPath = Get-PSOutput

# Kill the current PowerShell process used by MCP
Get-Process -Id $PID | Stop-Process -Force
```

Relaunch MCP with the built pwsh:
- Start it with: `<built-pwsh-path> -Command "Import-Module PowerShell.MCP -Force"`

Once connected:
1. Run `$PSVersionTable` and **include the output in the PR description** to prove you are running the development build
2. Run the same reproduction script from Step 2
3. Confirm the issue is resolved
4. Test edge cases and related scenarios

## Step 6: Run Tests

**Important:** Always use `Start-PSPester`, never `Invoke-Pester` directly.

Run the related test file:

```powershell
Import-Module ./build.psm1
Start-PSPester -Path <path-to-test-file> -UseNuGetOrg
```

For example, if fixing Get-Date:

```powershell
Start-PSPester -Path test/powershell/Modules/Microsoft.PowerShell.Utility/Get-Date.Tests.ps1 -UseNuGetOrg
```

Verify:
- All related tests pass
- No existing tests are broken
- Add new tests if the fix introduces new behavior

For xUnit tests (C# level):

```powershell
Start-PSxUnit
```

## Step 7: Submit PR

1. Create a working branch (never commit to master):

```powershell
git checkout -b fix/issue-description
```

2. Stage and commit changes:

```powershell
git add <files>
git commit -m "Fix description (#ISSUE_NUMBER)"
```

3. Create a PR with the following **mandatory** sections in the description:

```markdown
## Reproduction
<paste the reproduction script output from Step 2>

## Build
<paste `$PSVersionTable` output from the built pwsh>

## Fix
<describe the root cause and the fix>

## Verification
<paste the reproduction script output AFTER the fix, proving it is resolved>

## Test Results
<paste `Start-PSPester` output showing passed/failed/skipped counts>
```

**The PR is considered incomplete without all of these sections.**

---

## Firewall Notes (Copilot Coding Agent)

Copilot's sandbox has a firewall that may block external domains. Ensure the following are in the repository's Copilot coding agent allowlist (Settings > Copilot > Coding agent):

- `vsblob.vsassets.io` — NuGet package feeds (dotnet restore)
- `www.powershellgallery.com` — PowerShell Gallery
- `cdn.powershellgallery.com` — PowerShell Gallery CDN

Use `-UseNuGetOrg` flag with build commands to prefer public NuGet feeds.

## Tips

- `Split-Path (Get-PSOutput)` returns the build output directory
- Test files are typically under `./test/powershell/Modules/`
- Use `Get-Help <cmdlet>` in the built pwsh to verify help content changes
- When fixing a cmdlet, check both the C# source and the Pester tests
