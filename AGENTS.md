# AGENTS.md - Issue Fix Workflow

## MANDATORY — Read This First

**A PR without build and test evidence will be rejected.**

Every PR MUST contain these sections with actual command output (not placeholders):

1. **Reproduction** — output proving the bug exists (Step 2)
2. **Build** — `$PSVersionTable` output from the built pwsh (Step 3)
3. **Fix** — root cause and what you changed (Step 4)
4. **Verification** — output proving the bug is fixed (Step 5)
5. **Test Results** — `Start-PSPester` output with pass/fail counts (Step 6)

**Do NOT create a PR until you have all five sections.**

## How to Execute Commands

**Use the `invoke_expression` MCP tool for ALL commands.** Do NOT use `bash` with `pwsh -Command`.

The `invoke_expression` tool provides a **persistent PowerShell session**:
- `Import-Module ./build.psm1` stays loaded across all subsequent calls
- Variables, working directory, and environment persist between calls
- No need to re-import modules or re-set variables

If `invoke_expression` is not available, fall back to `bash` with `pwsh -Command`.

## Rules

- **ALWAYS use `invoke_expression`** for all PowerShell commands
- **NEVER use `dotnet build`** — use `Start-PSBuild`
- **NEVER use `Invoke-Pester`** — use `Start-PSPester`
- **NEVER reference issue numbers in source code**
- **NEVER skip building or testing** — code-only PRs will be rejected

---

## Step 1: Understand the Issue

Read the issue description. Identify affected source files.

## Step 2: Reproduce the Issue

Run the reproduction script using system pwsh **before building**. Save the output for the PR.

```
invoke_expression: <reproduction script>
```

## Step 3: Build

```
invoke_expression: Import-Module ./build.psm1
invoke_expression: Start-PSBootstrap -Scenario DotNet
invoke_expression: Start-PSBuild -Clean -PSModuleRestore -UseNuGetOrg
```

Run this and **save the output for the PR**:

```
invoke_expression: & (Get-PSOutput) -Command '$PSVersionTable'
```

> Note: `Import-Module` in the first call persists — no need to repeat it.

## Step 4: Fix the Code

- Use `is null` / `is not null` (not `== null` / `!= null`)
- Add `#nullable enable` near the top of modified files
- Follow existing code style

## Step 5: Rebuild and Verify

```
invoke_expression: Start-PSBuild -UseNuGetOrg
```

Run the reproduction script again with the built pwsh. **Save the output for the PR** — it must show the bug is fixed.

```
invoke_expression: & (Get-PSOutput) -Command '<reproduction script>'
```

## Step 6: Run Tests

```
invoke_expression: Start-PSPester -Path <test-file> -UseNuGetOrg
```

**Save the test output for the PR** — it must show pass/fail/skip counts.

## Step 7: Submit PR

Use this exact template for the PR description:

```
## Reproduction
<paste Step 2 output>

## Build
<paste Step 3 $PSVersionTable output>

## Fix
<describe root cause and fix>

## Verification
<paste Step 5 output showing bug is fixed>

## Test Results
<paste Step 6 Start-PSPester output>
```

Mark the PR as **ready for review** (not draft).