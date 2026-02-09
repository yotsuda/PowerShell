# AGENTS_REVIEW.md - PR Review Workflow for AI Coding Agents

This document provides step-by-step instructions for AI coding agents to review pull requests in the PowerShell repository using PowerShell.MCP.

## Workflow Overview

1. Understand the PR and linked issue
2. Reproduce the issue (using system pwsh, before building)
3. Build and test the PR
4. Review the code
5. Provide feedback

## Critical Rules

- **ALWAYS use `invoke_expression`** MCP tool for all PowerShell commands — NEVER use `bash` with `pwsh -Command`
- **NEVER use `dotnet build` directly** — always use `Start-PSBuild`
- **NEVER use `Invoke-Pester` directly** — always use `Start-PSPester`
- Be constructive and specific in feedback
- Always provide evidence (build logs, test results) for your assessment

> The `invoke_expression` tool provides a persistent PowerShell session — modules, variables, and working directory persist across calls. If `invoke_expression` is not available, fall back to `bash` with `pwsh -Command`.

---

## Step 1: Understand the PR and Linked Issue

- Read the PR description, linked issue, and all comments
- Understand what the PR is trying to fix or add
- Identify the affected files and components

## Step 2: Reproduce the Issue

**Before checking out the PR**, reproduce the linked issue using the system-installed pwsh:

1. Write a minimal script that demonstrates the bug described in the linked issue
2. Execute it and confirm the incorrect behavior
3. Document the reproduction result (expected vs actual)

This ensures:
- You understand the problem the PR is trying to solve
- You have a baseline to verify whether the PR actually fixes the issue
- You can judge if the fix is appropriate for the root cause

> **Note**: If the issue cannot be reproduced (e.g., already fixed, platform-specific, or requires internal API access), note this in your review.

## Step 3: Build and Test the PR

### Checkout the PR

```
invoke_expression: git clone https://github.com/PowerShell/PowerShell.git
invoke_expression: Set-Location PowerShell
invoke_expression: git fetch origin pull/<PR_NUMBER>/head:pr-<PR_NUMBER>
invoke_expression: git checkout pr-<PR_NUMBER>
```

### Build

```
invoke_expression: Import-Module ./build.psm1
invoke_expression: Start-PSBootstrap -Scenario DotNet
invoke_expression: Start-PSBuild -Clean -PSModuleRestore -UseNuGetOrg
```

Verify the build and record version info:

```
invoke_expression: & (Get-PSOutput) -Command '$PSVersionTable'
```

**Include the `$PSVersionTable` output in your review comment** to prove the build succeeded. If the build fails, document the errors — this is critical feedback for the PR author.

### Run Related Tests

Identify test files related to the changed code and run them:

```
invoke_expression: Start-PSPester -Path <path-to-related-test-file> -UseNuGetOrg
```

Document the test results (passed/failed/skipped counts).

### Verify the Fix (if applicable)

If the PR fixes a bug:
1. Switch to the built pwsh (kill current process, relaunch with built pwsh + PowerShell.MCP)
2. Run the reproduction script from the linked issue
3. Confirm the issue is actually resolved

## Step 4: Review the Code

Evaluate the code changes against these criteria:

### Correctness
- Does the fix actually address the root cause?
- Are there edge cases not handled?
- Could the fix introduce regressions?

### Coding Standards (CLAUDE.md)
- `is null` / `is not null` instead of `== null` / `!= null`
- `#nullable enable` present in modified files
- No issue numbers referenced in source code
- No debug code, ad-hoc comments, or unnecessary comments
- Follows existing code style and .editorconfig

### Test Coverage
- Are new tests added for new behavior?
- Do tests cover normal cases, error cases, and edge cases?
- No `$script:` or `$global:` variable prefixes in test variables

### File Format
- No BOM (Byte Order Mark)
- No whitespace on blank lines
- No trailing whitespace
- File ends with content + LF (no extra blank line at the end)

## Step 5: Provide Feedback

### If the PR is not viable (reject)

Clearly explain why, with evidence:

```markdown
### Build/Test Results
- Build: FAILED / PASSED
- Tests: X passed, Y failed, Z skipped

### Issues Found
1. [Specific problem with evidence]
2. [Another problem]

### Recommendation
This PR needs significant rework because [reason]. Consider [alternative approach].
```

### If the PR needs minor fixes (request changes)

Use **commit suggestion** format so the author can apply fixes with one click:

````markdown
### Build/Test Results
- Build: PASSED
- Tests: X passed, Y failed, Z skipped

### Suggested Changes

The null check should use `is null` per coding standards:

```suggestion
if (value is null)
{
    throw new ArgumentNullException(nameof(value));
}
```

Missing `#nullable enable` directive:

```suggestion
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#nullable enable
```
````

### If the PR looks good (approve)

```markdown
### Build/Test Results
- Build: PASSED
- Tests: X passed, 0 failed, Z skipped

### Review Summary
- Code changes are correct and address the root cause
- Coding standards are followed
- Test coverage is adequate
- No regressions detected

LGTM
```

---

## Tips

- Always build and test before reviewing code — a failing build is the most important feedback
- Focus on correctness first, style second
- When suggesting changes, use the `suggestion` code fence so GitHub renders the "Apply suggestion" button
- If unsure about a change, ask a question rather than requesting a change
- Check if the PR has CI results already — don't duplicate work unnecessarily
