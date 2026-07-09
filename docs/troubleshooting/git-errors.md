# Git: [WARNING] Unstaged files detected.

## Cause

This warning appears when Git finds files in the working tree that have changes but are not staged for commit.

## Resolution

1. Review changed files:

   ```bash
git status
```

2. Stage files you want to keep:

   ```bash
git add <file>
```

   or stage all changes:

   ```bash
git add .
```

3. If you do not want to keep the changes, discard them:

   ```bash
git restore <file>
```

   or discard all unstaged changes:

   ```bash
git restore .
```

4. Commit staged changes:

   ```bash
git commit -m "Your commit message"
```

## Notes

- If the warning appears during a scripted operation, make sure the script is running in the correct repository and that uncommitted changes are intended.
- Use `git diff` to inspect unstaged modifications before staging or discarding them.
