# CLAUDE.md - Instructions for Claude Code

## Project Overview
Fork of PowerShell/PowerShell. A cross-platform shell and scripting language built with C# (.NET).

## Mandatory Rules

1. **Never commit directly to master** — always create a working branch
2. **Never include issue numbers in source code** (no `#12345` in .cs, .ps1, etc.)
3. **Always include issue number in commit messages** (e.g., `Fix description (#XXXXX)`)
4. **Never commit without user approval**

## Build Instructions (Linux / GitHub Actions)

```bash
pwsh -Command "Import-Module ./build.psm1; Start-PSBuild -Clean -PSModuleRestore -UseNuGetOrg"
```

If the build fails, try bootstrapping first:
```bash
pwsh -Command "Import-Module ./build.psm1; Start-PSBootstrap -Scenario DotNet; Start-PSBuild -Clean -PSModuleRestore -UseNuGetOrg"
```

## Test Instructions

**Important:** Always use `Start-PSPester`, never use `Invoke-Pester` directly.
- `Start-PSPester` uses Pester v4 (same as CI)
- `Invoke-Pester` may use Pester v5, which has different variable scoping behavior

```bash
pwsh -Command "Import-Module ./build.psm1; Start-PSPester -UseNuGetOrg"
```

For xUnit tests:
```bash
pwsh -Command "Import-Module ./build.psm1; Start-PSxUnit"
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
