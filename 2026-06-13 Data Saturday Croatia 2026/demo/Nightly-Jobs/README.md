# Nightly SQL MI Cleanup Pipeline

This repo contains a pipeline that runs once per day and removes **stashed databases** that were marked for deletion after completed releases.

## Schedule
- **Cron:** `0 1 * * *`
- **When:** Every day at **01:00 UTC**
- **Branch:** `master`

## Purpose
During release provisioning, databases can be *stashed* for later reuse or rollback. Once a release is approved and completed, those stashed databases become obsolete.  
This pipeline ensures they are detected and deleted automatically, keeping the SQL MI environment clean and avoiding unnecessary storage costs.

## Implementation
- Runs on a **Windows hosted agent** (`windows-latest`).
- Uses the **automation** repository for cleanup scripts and config.
- Executes the script:
```

scripts/07-cleanup-stash.ps1 -settingsFile config/sqlmi-settings.json

```
