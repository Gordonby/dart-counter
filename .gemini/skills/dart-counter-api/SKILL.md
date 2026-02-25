---
name: dart-counter-api
description: Fetch and analyze data from the DartCounter API (api.dartcounter.net). Supports automated login, match history retrieval, and ASCII-art summary generation. Use this when the user wants to see their stats, authenticate, or export data for PowerBI/D3.
---

# DartCounter API Skill

Interact with DartCounter to authenticate, fetch profiles, match history, and detailed data.

## 1. Authentication (Getting a Bearer Token)

The API requires a Bearer token. You have two options:

### Option A: Automated Login (Recommended)
If your credentials are set in the environment (`$env:DARTCOUNTER_EMAIL` and `$env:DARTCOUNTER_PASSWORD`), you can automatically fetch and set a new token:

```powershell
.skills\dart-counter-api\scripts\auth.ps1
```
*You can also pass credentials directly: `.\auth.ps1 -Email "your@email.com" -Password "yourpassword"`*

### Option B: Manual Extraction (Fallback)
If you prefer not to use credentials, you can extract the token from your browser:
1. Open [app.dartcounter.net](https://app.dartcounter.net/) in Chrome/Edge and log in.
2. Press `F12` (DevTools) > **Network** tab.
3. Refresh the page and filter for `opensearch` or `profile`.
4. Under **Request Headers**, find `authorization`.
5. Copy the value after `Bearer ` and set it manually: `$env:dartcounter = "your_token_here"`.

## 2. Available Resources

### Scripts
- **`scripts/auth.ps1`**: Authenticates and sets the `$env:dartcounter` token for the session.
- **`scripts/fetch.ps1`**: A PowerShell script to make authenticated API calls (replacing Python).
- **`scripts/summary.ps1`**: Generates ASCII statistics and organizes JSON data into `data/exports/`.

### References
- **`references/api_docs.json`**: Reconstructed OpenAPI spec.

## 3. Workflows

### Dashboard Summary
Run the summary script to fetch recent matches, persist them to `data/exports/matches/`, and display a retro ASCII dashboard.

### Data Persistence
All fetched data is saved to `data/exports/` in a flat, date-stamped structure compatible with downstream tools like PowerBI or D3.
