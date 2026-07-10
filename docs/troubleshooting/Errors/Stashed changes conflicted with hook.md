# Pre-Commit Error: `Stashed changes conflicted with hook auto-fixes`

## Scenario

During a commit, pre-commit reports:

```text
[WARNING] Unstaged files detected.
[INFO] Stashing unstaged files...
...
[WARNING] Stashed changes conflicted with hook auto-fixes... Rolling back fixes...
```

## What It Means

This occurs when:

1. You have **staged changes**.
2. You also have **unstaged changes** in the same file(s).
3. A pre-commit hook (such as Black, End-of-File-Fixer, Trailing-Whitespace, or Markdownlint) automatically modifies one of the staged files.
4. Pre-commit then attempts to restore the unstaged changes it temporarily stashed.
5. Git cannot safely merge the hook's modifications with your unstaged edits.
6. Pre-commit rolls everything back to avoid data loss.

This is a protection mechanism, not a bug.

---

## Common Example

### File State

```text
docs/setup/docker_rebuild_run_book.md
```

### Staged Change

```markdown
# Docker Rebuild Run Book
```

### Unstaged Change

```markdown
# Troubleshooting
```

### Hook Fix

Markdownlint modifies headings:

```markdown
## Troubleshooting
```

When pre-commit restores the unstaged edits, Git encounters a conflict because both the hook and your unstaged work altered the same lines.

Result:

```text
[WARNING] Stashed changes conflicted with hook auto-fixes...
Rolling back fixes...
```

---

## Verify Current Status

Run:

```bash
git status
```

You will often see something similar to:

```text
Changes to be committed:
    modified: docs/setup/docker_rebuild_run_book.md

Changes not staged for commit:
    modified: docs/setup/docker_rebuild_run_book.md
```

This means the same file contains both staged and unstaged edits.

---

## Fix Option 1 (Recommended)

Stage Everything First

```bash
git add .
```

Verify:

```bash
git status
```

Expected:

```text
Changes to be committed:
    modified: docs/setup/docker_rebuild_run_book.md
```

Then run:

```bash
pre-commit run --all-files
```

Fix any reported issues.

Finally:

```bash
git add .
git commit -m "Apply markdownlint fixes"
```

---

## Fix Option 2

Temporarily stash unstaged changes:

```bash
git stash
```

Run:

```bash
pre-commit run --all-files
```

Commit:

```bash
git add .
git commit -m "Apply fixes"
```

Restore work:

```bash
git stash pop
```

---

## Fix Option 3

The most reliable recovery for documentation projects:

```bash
git add .
pre-commit run --all-files
git add .
git commit -m "Apply pre-commit fixes"
```

This is especially useful for:

```text
Markdownlint
Black
Trailing-whitespace
End-of-file-fixer
Check-yaml
```

because they frequently modify files automatically.

---

## Docker AI Assistant Example

From your recent workflow, the likely sequence is:

```bash
git add docs/setup/docker_rebuild_run_book.md
```

but additional edits remained unstaged.

Then:

```bash
git commit -m "Update run book"
```

Pre-commit detected:

```text
MD025 Multiple H1 headings
```

Attempted to fix or validate the file.

However, the file also contained unstaged changes, causing:

```text
[WARNING] Stashed changes conflicted with hook auto-fixes...
Rolling back fixes...
```

---

## Recovery Steps

### 1. Check Status

```bash
git status
```

### 2. Stage Everything

```bash
git add .
```

### 3. Run Hooks Manually

```bash
pre-commit run --all-files
```

### 4. Fix Remaining Errors

For example, resolve:

```text
MD025 Multiple top-level headings
```

by leaving only one:

```markdown
# Docker Rebuild and Run Book
```

and changing later headings to:

```markdown
## Troubleshooting
## Validation Checks
```

### 5. Re-stage

```bash
git add .
```

### 6. Commit

```bash
git commit -m "Apply markdownlint fixes"
```

---

## Quick Diagnostic Commands

Show staged files:

```bash
git diff --cached --name-only
```

Show unstaged files:

```bash
git diff --name-only
```

Check status:

```bash
git status
```

Run all hooks:

```bash
pre-commit run --all-files
```

---

## Summary

| Message | Meaning | Action |
| --- | --- | --- |
| `Unstaged files detected` | Modified files exist outside the commit | Usually informational |
| `Stashing unstaged files` | Pre-commit is protecting your work | Normal |
| `Conflicted with hook auto-fixes` | Hook changed a file that also has unstaged edits | Stage all changes or stash first |
| `Rolling back fixes` | Pre-commit restored the previous state to avoid data loss | Fix, stage, rerun |

### Recommended Command Sequence

```bash
git status
git add .
pre-commit run --all-files
git add .
git commit -m "Apply pre-commit fixes"
```

For your `docker_ai_assistant` project, this sequence resolves most Markdownlint, Black, and MkDocs/Zensical pre-commit conflicts.
