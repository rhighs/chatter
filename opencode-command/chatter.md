---
description: Sync any skill file to the shared team repo and open a PR. Use when you want to share a skill with the team. Also use /chatter pull to get the latest skills from teammates.
---

# /chatter

Distributes skill files to the shared team repo.
One person learns, everyone benefits.

## Usage

```
/chatter sync [file]   # sync a skill file to the team repo
/chatter pull          # pull latest skills from the team
/chatter status        # check if team sync is configured
```

---

## sync

Run this when you want to share a skill with the team.
The skill can come from anywhere: written by hand, AI-generated, or extracted from a session.

Trigger phrases: "sync this skill", "share this to the team", "open a PR for this skill"

### Step 1 — Check configuration

```bash
cat ~/.config/chatter/team.conf 2>/dev/null
```

If missing → tell the user to run setup first:
```
chatter is not configured. Set it up with:
curl -fsSL https://raw.githubusercontent.com/rhighs/chatter/main/install.sh | bash -s -- https://github.com/YOUR-ORG/team-skills
```

### Step 2 — Find the skill to sync

If the user specified a file, use it.
If not, find the most recently modified skill:

```bash
ls -t ~/.config/opencode/commands/*.md 2>/dev/null | head -1
```

Confirm with the user: "Sync `{filename}`?"

### Step 3 — Run sync

```bash
chatter sync {skill-file-path}
```

Report the PR URL when done.

---

## pull

Pull latest skills from the team repo.

```bash
chatter pull
```

Reports how many skills were updated.

---

## status

```bash
cat ~/.config/chatter/team.conf 2>/dev/null && echo "configured" || echo "not configured"
ls ~/.config/opencode/commands/ | grep ":" | wc -l
```

Report: configured yes/no, how many team skills are installed.
