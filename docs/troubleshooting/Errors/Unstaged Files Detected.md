# Pre-Commit Warning: `Git: [WARNING] Unstaged files detected`

## Scenario

During a Git commit or pre-commit execution, the following warning appears:

```text
[WARNING] Unstaged files detected.
```

Sometimes you may also see:

```text
[WARNING] Unstaged files detected.
[INFO] Stashing unstaged files to /Users/username/.cache/pre-commit/patchxxxxx.
```

## What It Means

This warning indicates that Git has detected files that have been modified but are **not included in the current commit**.

Pre-commit temporarily stashes these unstaged changes so it can safely run checks against only the files that are part of the commit.

This is typically an informational message and **not an error**.

---

## Why It Happens

### Example 1 – Only Some Changes Were Staged

Modify two files:

```bash
app/main.py
docs/testing.md
```

Stage only one:

```bash
git add app/main.py
```

Check status:

```bash
git status
```

Output:

```text
Changes to be committed:
    modified: app/main.py

Changes not staged for commit:
    modified: docs/testing.md
```

When committing:

```bash
git commit -m "Update application"
```

Pre-commit displays:

```text
[WARNING] Unstaged files detected.
```

because `docs/testing.md` contains changes not included in the commit.

---

### Example 2 – Generated Documentation Exists

In a MkDocs/Zensical project:

```text
docs/
site/
mkdocs.yml
```

You may stage:

```bash
git add docs/
```

but leave generated files unstaged:

```text
site/index.html
site/search/search_index.json
```

Pre-commit reports:

```text
[WARNING] Unstaged files detected.
```

because Git sees modified files outside the commit.

---

## Verify What Is Unstaged

Run:

```bash
git status
```

Example:

```text
Changes to be committed:
    modified: app/main.py

Changes not staged for commit:
    modified: README.md
    modified: docs/testing.md
```

Any file listed under:

```text
Changes not staged for commit
```

causes the warning.

---

## View Unstaged Changes

Display all unstaged modifications:

```bash
git diff
```

Display a specific file:

```bash
git diff docs/testing.md
```

---

## Option 1 – Commit Only Current Changes

If the unstaged files should not be part of this commit:

```bash
git commit -m "Update application"
```

No action is required.

The warning is informational.

---

## Option 2 – Include All Changes

Stage everything:

```bash
git add .
```

Verify:

```bash
git status
```

Commit:

```bash
git commit -m "Update application and documentation"
```

---

## Option 3 – Discard Unwanted Changes

Discard unstaged modifications:

```bash
git restore .
```

Or a specific file:

```bash
git restore docs/testing.md
```

Verify:

```bash
git status
```

---

## Option 4 – Temporarily Save Work

If changes are not ready to commit:

```bash
git stash
```

Verify:

```bash
git status
```

Output:

```text
nothing to commit, working tree clean
```

Restore later:

```bash
git stash pop
```

---

## Docker AI Assistant Example

Project structure:

```text
docker_ai_assistant/
├── app/
├── tests/
├── docs/
├── site/
├── mkdocs.yml
└── .pre-commit-config.yaml
```

Example status:

```bash
git status
```

Output:

```text
Changes to be committed:
    modified: app/main.py

Changes not staged for commit:
    modified: site/index.html
    modified: docs/testing.md
```

Commit:

```bash
git commit -m "Fix FastAPI route"
```

Output:

```text
[WARNING] Unstaged files detected.
[INFO] Stashing unstaged files...
black................................................Passed
flake8...............................................Passed
```

This is normal behaviour.

Pre-commit temporarily protects the unstaged files while validating the commit.

---

## Troubleshooting Checklist

### Check repository status

```bash
git status
```

### See unstaged changes

```bash
git diff
```

### Stage everything

```bash
git add .
```

### Unstage a file

```bash
git restore --staged <file>
```

### Discard unstaged changes

```bash
git restore .
```

### Temporarily save changes

```bash
git stash
```

### Restore stashed changes

```bash
git stash pop
```

---

## Summary

| Message | Meaning | Action Required |
| ---------- | ---------- | ---------- |
| `[WARNING] Unstaged files detected` | Git found changes not included in commit | Usually none |
| `Stashing unstaged files` | Pre-commit is protecting your work | None |
| `Passed` | Hook completed successfully | None |
| `Failed` | Hook detected a problem | Review and recommit |
| `Error` | Hook execution issue | Investigate configuration |

## Key Point

```text
[WARNING] Unstaged files detected.
```

is generally not a problem. It simply means that Git and pre-commit have found modified files that are not part of the current commit and are temporarily protecting them while validation runs.
