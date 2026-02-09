# CLAUDE.md - Instructions for Claude Code

## Project Overview
Fork of PowerShell/PowerShell. A cross-platform shell and scripting language built with C# (.NET).

## Mandatory Rules

1. **Never commit directly to master** — always create a working branch
2. **Never include issue numbers in source code** (no `#12345` in .cs, .ps1, etc.)
3. **Always include issue number in commit messages** (e.g., `Fix description (#XXXXX)`)
4. **Never commit without user approval**

## How to Execute Commands

**Use the `invoke_expression` MCP tool for ALL commands.** Do NOT use `bash` with `pwsh -Command`.

The `invoke_expression` tool provides a **persistent PowerShell session** — modules, variables, and working directory persist across calls. Import once, use everywhere.

If `invoke_expression` is not available, fall back to `bash` with `pwsh -Command`.

## Build Instructions

```
invoke_expression: Import-Module ./build.psm1
invoke_expression: Start-PSBootstrap -Scenario DotNet
invoke_expression: Start-PSBuild -Clean -PSModuleRestore -UseNuGetOrg
```

> Note: `Import-Module` persists in the session — no need to repeat it for subsequent commands.

## Test Instructions

**Important:** Always use `Start-PSPester`, never use `Invoke-Pester` directly.
- `Start-PSPester` uses Pester v4 (same as CI)
- `Invoke-Pester` may use Pester v5, which has different variable scoping behavior

```
invoke_expression: Start-PSPester -Path <test-file> -UseNuGetOrg
```

For xUnit tests:
```
invoke_expression: Start-PSxUnit
```

## PR Submission Rules

1. **Build must pass** before creating a PR
2. **Run related tests** and confirm all pass
3. **Verify no existing tests are broken**
4. PR title should be concise and in English
5. PR body must describe the purpose and scope of changes
6. Commit message must include the issue number in parentheses at the end, e.g., `Fix description (#XXXXX)`

## Coding Standards

- Follow existing code style in the codebase
- Comply with .editorconfig settings
- Add XML documentation comments for public members
- Enable nullability (`#nullable enable` near the top of the file)
- Use `is null` / `is not null` instead of `== null` / `!= null`
- Do not leave debug code, ad-hoc comments, or unnecessary comments
- Do not reference issue numbers or issue body text in code comments
- New features must include tests

## Test Guidelines

- Do not use `$script:` or `$global:` variable prefixes in test variables
- Cover normal cases, error cases, and edge cases
- Structure tests logically and clearly — concise, comprehensive, well-ordered
- Test files are typically under `./test/powershell/Modules/`

## Quality Checklist

### File Format
- No BOM (Byte Order Mark)
- No whitespace on blank lines
- No trailing whitespace
- File ends with content + LF (no extra blank line at the end)

### Content
- No issue references in source code
- No ad-hoc comments explaining what the bug was
- XML docs should not contain implementation details
- Existing code style is preserved
