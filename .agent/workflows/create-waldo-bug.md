---
description: create standard Waldo (Search Experience) Jira issue
---

1. Gather the story/bug context, acceptance criteria, and supporting assets (links, screenshots, reproductions).
2. Open the Jira MCP issue-creation form.
3. Fill the required fields:
   - Project: `CXE`
   - Issue Type: choose the one that fits (usually `Bug` for defects, `Story` for feature work).
   - Team (custom field `customfield_10001`): select **Waldo (Search Experience)**.
   - Found In (radio `customfield_10432`): choose the environment where the defect was originally detected (options include **Local**, **Dev**, **QA**, **Production**; pick the highest environment where it reproduces).
   - Severity (select `customfield_10069`): map to SEV-1/2/3/4 per impact.
   - Frequency (select `customfield_10068`): choose 5 = 100% reproducible, 3 = ~50%, 1 = rare.
   - Reproduced In (multi-check `customfield_10070`): list every environment/platform where you verified the issue (e.g., Production, QA, Web, Android, iOS).
4. Add a concise summary ("<area>: <problem/opportunity>").
5. Write a clear description covering:
   - Background / why
   - Steps to reproduce (or requirements)
   - Expected vs actual (if bug)
   - Assets / links (Figma, logs, etc.)
6. Double-check components, labels, priority, and attachments align with the request.
7. Submit the issue and share the new Jira link with the requestor.

## MCP Tool Notes (`createJiraIssue`)

Custom fields **must** be passed via the `additional_fields` parameter (not `fields` or top-level params). Format reference:

```json
{
  "customfield_10432": { "id": "11216" },
  "customfield_10001": "768ec892-2e78-46bf-b014-e937628fd2b2",
  "customfield_10323": { "id": "11051" },
  "customfield_10069": { "id": "10987" },
  "customfield_10068": { "id": "10106" },
  "customfield_10070": [{ "id": "10113" }, { "id": "10118" }],
  "components": [{ "id": "10851" }, { "id": "10852" }],
  "labels": ["waldo"]
}
```

| Field         | Key                 | Format            | Common Values                                                             |
| ------------- | ------------------- | ----------------- | ------------------------------------------------------------------------- |
| Team          | `customfield_10001` | plain string UUID | `768ec892-2e78-46bf-b014-e937628fd2b2` (Waldo)                            |
| Found In      | `customfield_10432` | `{"id": "..."}`   | Local `11220`, Dev `11219`, QA `11218`, Production `11216`                |
| Root Cause    | `customfield_10323` | `{"id": "..."}`   | Needs Triage `11051`                                                      |
| Severity      | `customfield_10069` | `{"id": "..."}`   | SEV-1 `10985`, SEV-2 `10986`, SEV-3 `10987`, SEV-4 `10988`                |
| Frequency     | `customfield_10068` | `{"id": "..."}`   | 100% `10106`, 50% `10107`, Rare `10108`                                   |
| Reproduced In | `customfield_10070` | `[{"id": "..."}]` | Production `10113`, QA `10115`, Web `10118`, Android `10119`, iOS `10120` |
| Components    | `components`        | `[{"id": "..."}]` | waldo `10851`, Web `10852`, App `10832`                                   |