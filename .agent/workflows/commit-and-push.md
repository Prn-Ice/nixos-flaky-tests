---
description: Review all staged/unstaged changes, group into logical commits following existing patterns, and push
---

# Steps

1. Check git status to see all staged and unstaged changes:
// turbo

```bash
git status
```

2. Review recent commit history to understand the commit message conventions:
// turbo

```bash
git log --oneline -20
```

3. Review all diffs to understand what each change is about:
// turbo

```bash
git diff --stat
git diff --cached --stat
```

4. Read the actual diffs for each changed file to categorize them:
// turbo

```bash
git diff <file>          # for unstaged changes
git diff --cached <file> # for staged changes
```

5. Group changes into logical commits based on the existing patterns. Common prefixes:
   - `feat:` — new features or packages
   - `fix:` — bug fixes
   - `docs:` — documentation changes
   - `chore:` — maintenance, updates, formatting, cleanups
   - `refactor:` — code restructuring

6. **Important**: Unstage everything first to avoid accidentally mixing staged files into the wrong commit:

```bash
git reset HEAD -- .
```

7. Stage and commit each group separately, in dependency order (e.g. flake.lock first, then config cleanups, then new features):

```bash
git add <files-for-group> && git commit -m "<prefix>: <description>"
```

8. Verify the commit log looks correct:
// turbo

```bash
git log --oneline -<N>
```

9. Push to remote:

```bash
git push
```

## Notes

- Leave untracked build artifacts (e.g. `result` symlinks) alone
- If a staged file accidentally gets into the wrong commit, use `git reset --soft HEAD~1` to undo and redo
- Prefer multiple small focused commits over one large commit
- Match the style of existing commit messages (lowercase after prefix, no period)
