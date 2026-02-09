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

## Rules

- **NEVER use `dotnet build`** — use `Start-PSBuild`
- **NEVER use `Invoke-Pester`** — use `Start-PSPester`
- **NEVER reference issue numbers in source code**
- **NEVER skip building or testing** — code-only PRs will be rejected

---

## Step 1: Understand the Issue

Read the issue description. Identify affected source files.

## Step 2: Reproduce the Issue

Run the reproduction script using system pwsh **before building**. Save the output for the PR.

## Step 3: Build

```powershell
Import-Module ./build.psm1
Start-PSBootstrap -Scenario DotNet
Start-PSBuild -Clean -PSModuleRestore -UseNuGetOrg
```

Run this and **save the output for the PR**:

```powershell
& (Get-PSOutput) -Command '$PSVersionTable'
```

## Step 4: Fix the Code

- Use `is null` / `is not null` (not `== null` / `!= null`)
- Add `#nullable enable` near the top of modified files
- Follow existing code style

## Step 5: Rebuild and Verify

```powershell
Import-Module ./build.psm1
Start-PSBuild -UseNuGetOrg
```

Run the reproduction script again with the built pwsh. **Save the output for the PR** — it must show the bug is fixed.

## Step 6: Run Tests

```powershell
Import-Module ./build.psm1
Start-PSPester -Path <test-file> -UseNuGetOrg
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