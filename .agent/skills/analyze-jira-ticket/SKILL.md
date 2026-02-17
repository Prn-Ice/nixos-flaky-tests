---
name: analyze-jira-ticket
description: Analyze a Jira ticket to assess complexity, identify code changes needed, and estimate effort
---

# Analyze Jira Ticket Workflow

Use this workflow to analyze a Jira ticket and provide a comprehensive assessment.

## Steps

### 1. Fetch Jira Ticket Details

// turbo
Use the Atlassian CLI to fetch the ticket:

```
acli jira auth login --web
acli jira workitem view <TICKET_ID> --json | cat
```

Extract key information:

- Summary/Title
- Description
- Issue Type (Bug, Task, Story, etc.)
- Priority
- Status
- Parent ticket (if any)
- Attachments/screenshots

### 2. Identify Relevant Keywords

From the ticket description, identify:

- Feature names (e.g., "Share App", "Search", "Profile")
- UI components mentioned
- Specific behaviors or flows
- Error messages (for bugs)

### 3. Search Codebase for Related Code

// turbo
Use grep_search and find_by_name to locate relevant files:

```
grep_search for feature keywords in lib/ directory
find_by_name for files matching feature patterns
```

Common search patterns:

- Widget/screen names from the UI
- Function names mentioned in the ticket
- Localization keys
- Test files for context

### 4. Analyze Code Structure

// turbo
View the identified files to understand:

- Current implementation
- Data flow
- Dependencies (imports, packages)
- Related test files

### 5. Check Localization (if UI text changes needed)

// turbo
The translations are in external package `kwcon_translations`:

```yaml
kwcon_translations:
  git:
    url: git@github.com:KWRI/kwcon-translations.git
    path: l10n/flutter-app
```

Search for existing localization keys in the codebase.

### 6. Generate Analysis Report

Provide a structured response with:

#### Summary

Brief description of what the ticket is about.

#### Is It Easy to Fix?

Assessment with reasoning:

- **Easy**: Single file change, text update, or simple logic modification
- **Medium**: Multiple files, requires understanding of data flow
- **Hard**: Architecture changes, multiple packages, complex logic

#### Where Changes Need to Be Made

| File/Location | Change Description   |
| ------------- | -------------------- |
| path/to/file  | What needs to change |

#### Estimated Effort

- **Low**: < 2 hours
- **Medium**: 2-8 hours
- **High**: > 8 hours

#### Additional Considerations

- Testing requirements
- Related tickets
- Potential risks
- Dependencies on external packages
