---
name: create-flutter-pr
description: Document repository standards and create a reusable workflow guide from PR templates and conventions.
---

# Create Repository Workflow Documentation

You are tasked with analyzing a repository's pull request processes and standardizing them into a reusable workflow guide. This is useful for ensuring consistent PR practices and automating workflows across teams.

## Task Overview

1. **Read the Jira Ticket**
   - Fetch the ticket details (CXE-XXXXX) using Atlassian MCP tools
   - Determine issue type: Bug, Feature, Task, etc.
   - Extract summary, description, and acceptance criteria
   - This determines whether to use `feature/` or `bugfix/` branch prefix
   - Note: Bug fixes → `bugfix/`, Features/Tasks → `feature/`

2. **Locate and Read Templates**
   - Find the PR template file (typically `.github/pull_request_template.md`)
   - Read the README.md for any mentioned conventions
   - Note the structure and required sections
   - Follow the template strictly when creating the PR, do not deviate, do not invent new sections

3. **Analyze Recent PRs and Commits**
   - List recent merged PRs (10+ examples)
   - Extract branch naming patterns from PR metadata
   - Review commit message formats from git history
   - Identify common patterns in PR titles and descriptions

4. **Document Conventions Found**
   - Branch naming: Extract pattern with type prefix and ticket ID
   - Commit message: Extract pattern for consistency
   - PR title: Note if it matches commit format
   - PR body structure: Map out all required sections
   - Testing requirements: Note if tests are mandatory
   - Review process: Note typical reviewers and timeline

5. **Create a PR Using the Discovered Standards**
   - Determine branch type from Jira ticket issue type (Bug → bugfix/, Feature → feature/)
   - Create branch: `[type]/CXE-[ID]/[kebab-case-description]`
   - Commit staged changes using format: `CXE-[ID]: [Short description]`
   - If files are already staged, skip staging step
   - Push to origin and create PR using the template
   - Fill all required sections with clear information from Jira ticket
   - Include links to the Jira ticket
   - Keep the PR body concise and relevant

6. **Summarize Findings** (Optional)
   - If requested, document workflow standards discovered
   - Include recommendations for workflow automation
   - Provide a reference table of all standards discovered

## Output Deliverables

1. **PR Created** - Using discovered standards, correct type (feature/bugfix) based on Jira
2. **Standards Identified** - Branch pattern, commit format, PR title format
3. **Examples** - Real PR examples from repository history (if requested)

## Key Information to Extract

- Jira issue type: Bug (bugfix/) vs Feature/Task (feature/)
- Branch pattern: `[type]/CXE-[ID]/[description]`
- Commit format: `CXE-[ID]: [Short description]`
- PR title format: Should match commit or follow similar pattern
- PR template sections: Count and list each required section
- Test requirements: Mandatory or optional?
- Reviewer patterns: Who typically reviews?
- Merge timeline: How quickly are PRs typically merged?

## Success Criteria

- ✅ Jira ticket fetched and issue type determined
- ✅ Correct branch type (bugfix/ or feature/) selected based on issue type
- ✅ All PR template sections documented
- ✅ Branch naming convention identified and followed
- ✅ Commit message format discovered and used
- ✅ Recent PRs analyzed (minimum 5-10 examples)
- ✅ PR created following discovered standards and Jira context
- ✅ Recommendations for automation provided (if requested)
