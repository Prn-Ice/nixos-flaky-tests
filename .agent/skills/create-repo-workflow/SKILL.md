---
name: create-repo-workflow
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

4. **Cache Repository Conventions**
   - Store discovered patterns in a local cache file for future use
   - Branch naming: Extract and cache pattern with type prefix and ticket ID
   - Commit message: Extract and cache pattern for consistency
   - PR title: Cache format if it matches commit pattern
   - PR body structure: Cache required sections and structure
   - Testing requirements: Cache if tests are mandatory
   - Review process: Cache typical reviewers and timeline
   - Update cache when new patterns are discovered

5. **Create a PR Using Cached Standards**
   - Load repository conventions from cache or discover if not cached
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

## Cache Implementation

Store repository conventions directly in this skill file as a YAML frontmatter cache:

```yaml
---
name: create-repo-workflow
description: Document repository standards and create a reusable workflow guide from PR templates and conventions.
cache:
  org/repo-name:
    last_updated: "2026-02-05T16:28:00Z"
    conventions:
      branch_pattern: "[type]/CXE-[ID]/[description]"
      commit_format: "CXE-[ID]: [Short description]"
      pr_title_format: "CXE-[ID]: [Short description]"
      pr_sections: ["Description", "Testing", "Screenshots"]
      testing_required: true
      typical_reviewers: ["@user1", "@user2"]
      merge_timeline: "1-2 days"
---
```

The cache is stored in the YAML frontmatter and updated automatically when new patterns are discovered.

## Output Deliverables

1. **PR Created** - Using cached standards, correct type (feature/bugfix) based on Jira
2. **Cache Updated** - Repository conventions stored/updated in local cache
3. **Efficiency Gains** - Faster subsequent PR creation using cached patterns

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
