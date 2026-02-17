---
description: Document repository standards and create a reusable workflow guide from PR templates and conventions.
---

# Create Repository Workflow Documentation

You are tasked with creating PRs following this repository's established standards.

## Repository-Specific Standards (Pre-discovered)

### Branch Naming

- **Feature/Story/Task:** `feature/CXE-[ID]/[kebab-case-description]`
- **Bug:** `bugfix/CXE-[ID]/[kebab-case-description]`

### Commit Message Format

```
CXE-[ID]: [Short description]
```

### PR Title Format

```
CXE-[ID]: [Short description]
```

(Same as commit message)

### PR Template Location

`.github/pull_request_template.md`

### PR Template Sections

1. **Summary** - Short description
2. **JIRA** - Link format: `[CXE-ID](https://kwri.atlassian.net/browse/CXE-ID)`
3. **Problem Details** - CONTEXT and WHY
4. **Solution** - What modifications were made
5. **Result** - Before vs After, screenshots/GIFs
6. **Docs** - Links to Confluence or related docs (N/A if none)
7. **Sanity Check Steps** - Manual testing steps
8. **Checklist** - Unit tests, Docs, iOS/Android/Web, Acceptance criteria

---

## Workflow Steps

### 1. Fetch Jira Ticket Details

// turbo

```
mcp_atlassian-mcp-server_getJiraIssue with cloudId: kwri.atlassian.net and issueIdOrKey: CXE-XXXXX
```

Determine branch type from issue type:

- Bug → `bugfix/`
- Story, Feature, Task → `feature/`

### 2. Create Branch from Main

// turbo

```bash
git checkout main && git pull origin main
git checkout -b [type]/CXE-[ID]/[kebab-case-description]
```

### 3. Stage Relevant Files Only

```bash
git add [specific files for this ticket]
```

### 4. Commit with Standard Format

```bash
git commit -m "CXE-[ID]: [Short description]"
```

### 5. Push Branch

```bash
git push -u origin [branch-name]
```

### 6. Create PR Using Template

// turbo

```bash
gh pr create --title "CXE-[ID]: [Short description]" --body "[PR body following template]"
```

Fill all sections from the template:

- Summary from Jira ticket
- Link to Jira ticket
- Problem/Solution from implementation context
- Testing steps
- Mark checklist items appropriately

---

## Quick Reference

| Element        | Pattern                                              |
| -------------- | ---------------------------------------------------- |
| Feature branch | `feature/CXE-[ID]/[description]`                     |
| Bugfix branch  | `bugfix/CXE-[ID]/[description]`                      |
| Commit message | `CXE-[ID]: [description]`                            |
| PR title       | `CXE-[ID]: [description]`                            |
| Jira link      | `[CXE-ID](https://kwri.atlassian.net/browse/CXE-ID)` |

## Success Criteria

- ✅ Correct branch type based on Jira issue type
- ✅ Branch created from latest main
- ✅ Only relevant files staged
- ✅ Commit message follows format
- ✅ PR created with all template sections filled
- ✅ Jira ticket linked
