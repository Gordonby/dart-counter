# Dart Counter AI Skill

The [DartCounter app](https://dartcounter.net/) is awesome for inputting scores, even better with the Omni auto scoring system. 
They don't however make it easy to get your data out of the app.
The purpose of this repo is to easily free your data, allowing you to save it safely and perform analysis of it.

## What can it do

- **Login to the API**: Securely authenticate using your DartCounter credentials.
- **Data Persistence**: Automatically save your match history and user profile to JSON files for offline analysis.
- **ASCII Dashboard**: Generate a retro-style statistics summary directly in your terminal.
- **Leg-Level Insights**: Breakdown performance by individual legs for multi-leg matches.

```text
    +--------------------------------------------------+
    |                DARTCOUNTER STATS                 |
    +--------------------------------------------------+
    | TOTAL GAMES:   68                                |
    | WIN RATE:      38.2%                             |
    | AVG 3-DART:    41.01                             |
    | BEST AVG:      60.12                             |
    +--------------------------------------------------+
    |           RECENT MATCH PERFORMANCE               |
    +--------------------------------------------------+
    | 2026-02-25 | WON  | 2-0   | AVG: 37.11      |    |
    |            |      |       |  - L1: 51.8     |    |
    |            |      |       |  - L2: 28.9     |    |
    | 2026-02-25 | LOSS | 0-1   | AVG: 40.42      | 🤖 |
    | 2026-02-25 | WON  | 1-0   | AVG: 48.48      | 🤖 |
    | 2026-02-25 | WON  | 1-0   | AVG: 57.81      | 🤖 |
    | 2026-02-25 | LOSS | 0-1   | AVG: 38.42      | 🤖 |
    +--------------------------------------------------+
```

## Getting started

### 1. Interact with AI

This project is designed as an **AI Skill**. If you're using a compatible AI CLI (like Gemini CLI), you don't need to remember script paths or parameters. Just ask:

- *"Authenticate and show my dashboard"*
- *"Show my stats for 2026"*
- *"How am I performing against DartBot?"*
- *"Fetch my recent matches and show the leg breakdown"*

The AI autonomously handles the authentication, script execution, and data parsing.

### 2. Manual CLI Usage

If you prefer to run the scripts directly, you can use the following:

#### Authentication
The skill requires a Bearer token. Automate this by providing your credentials:

```powershell
# Authenticate and set the session token
.skills\dart-counter-api\scripts\auth.ps1 -Email "your@email.com" -Password "yourpassword"
```

#### Fetch & Summary
To fetch your latest data and see your dashboard:

```powershell
# Fetch matches (defaults to 250 limit) and show stats
.skills\dart-counter-api\scripts\summary.ps1
```

### 3. Data Structure

All fetched data is persisted to the `data/exports/` directory:
- `data/exports/matches/`: Contains timestamped JSON files of your match history.
- `api_response/`: Temporary storage for raw API responses like `user_profile.json`.

### 4. Installation in other AI CLIs

The `.gemini/skills/dart-counter-api` folder follows the **Agent Skills** standard (Markdown + YAML frontmatter). You can install this skill in other compatible AI CLIs by symlinking or copying the folder into their respective skill registries:

- **GitHub Copilot CLI / GitHub CLI**:
  Copy or symlink the folder to `.github/skills/` in your repository.
  ```powershell
  New-Item -ItemType SymbolicLink -Path ".github/skills/dart-counter-api" -Target ".gemini/skills/dart-counter-api"
  ```
- **Other Agents**: Most agents that support local tools or "System Prompts" can ingest the `SKILL.md` file to understand how to call the PowerShell scripts.

## Technical Details

The skill is built using PowerShell for cross-platform compatibility (Windows/Core) and is structured for discovery by AI agents via the `.gemini/skills/` directory.

- **`auth.ps1`**: Handles the `POST /login` flow and manages the `$env:dartcounter` token.
- **`summary.ps1`**: Queries `GET /matches/opensearch` and renders the ASCII dashboard.
- **`fetch.ps1`**: A utility script for making generic authenticated calls to the API.
- **`SKILL.md`**: The system instructions that teach the AI how to use these tools.

## Origin story

Forked from https://github.com/Mark-McCracken/dart-counter-aggregator, as my only reference to the API (the OpenAPI spec has long since disappeared from the link).

I'm not a massive python fan, and i'm quite into my AI CLI's at the moment - so i've turned this into an AI skill to capture the data which can then be visualised in a variety of ways.
