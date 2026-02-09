# Copilot Instructions

## Rules

- **ALWAYS use `invoke_expression`** for ALL commands — NEVER use `bash` with `pwsh -Command`
- **NEVER use `dotnet build`** — use `Start-PSBuild` via `invoke_expression`
- **NEVER use `Invoke-Pester`** — use `Start-PSPester` via `invoke_expression`
- **NEVER reference issue numbers in source code**
- **NEVER skip building or testing** — code-only PRs will be rejected
- **NEVER add `#nullable enable`** unless the file already has it
- **Do NOT include unrelated changes** — no refactoring, no modernization, no style changes outside the fix

## How to Execute Commands

Use the `invoke_expression` MCP tool. It provides a **persistent PowerShell session**:
- `Import-Module ./build.psm1` stays loaded across all subsequent calls
- Variables, working directory, and environment persist between calls

If `invoke_expression` is not available, fall back to `bash` with `pwsh -Command`.

---

## Issue Fix Workflow

**A PR without build and test evidence will be rejected.** Follow every step in order.

### Step 1: Understand the Issue

Read the issue description. Identify affected source files.

### Step 2: Reproduce the Issue — BEFORE Any Code Changes

**Do NOT touch any source code until this step is complete.**

Copy the reproduction code from the issue's "Steps to reproduce" and execute it:

```
invoke_expression: <paste the code from "Steps to reproduce">
```

Confirm the output matches the issue's "Actual behavior". Save the output — it goes in the **Reproduction** section of the PR.

### Step 3: Build

```
invoke_expression: Import-Module ./build.psm1
invoke_expression: Start-PSBootstrap -Scenario DotNet
invoke_expression: Start-PSBuild -Clean -PSModuleRestore -UseNuGetOrg
```

Save the `$PSVersionTable` output:

```
invoke_expression: & (Get-PSOutput) -Command '$PSVersionTable'
```

### Step 4: Fix the Code

**Do NOT write any fix code until Step 2 and Step 3 are complete.**

- Use `is null` / `is not null` (not `== null` / `!= null`)
- Follow existing code style

### Step 5: Rebuild and Verify

Rebuild:

```
invoke_expression: Start-PSBuild -UseNuGetOrg
```

Run the SAME reproduction script from Step 2 with the built pwsh:

```
invoke_expression: & (Get-PSOutput) -Command '<the same code you ran in Step 2>'
```

Confirm the output now matches the issue's "Expected behavior". Save the output — it goes in the **Verification** section of the PR.

### Step 6: Run Tests

```
invoke_expression: Start-PSPester -Path <test-file> -UseNuGetOrg
```

Save the test output — it must show pass/fail/skip counts.

### Step 7: Submit PR

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
