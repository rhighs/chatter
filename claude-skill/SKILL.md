---
name: chatter
description: |
  Sync skill files to the shared team repo. Triggers:
  "share this skill", "sync to team", "open a PR for this", /chatter.
  Also handles: "pull team skills", "get latest from team".
version: 1.0.0
allowed-tools:
  - Bash
  - Read
---

# chatter

Distributes skill files to the shared team repo via PR.

## When to Use

- User says "share this with the team" or "open a PR for this skill"
- User says "pull latest skills" or "get team skills"

## sync

### Check config first

```bash
cat ~/.config/chatter/team.conf 2>/dev/null
```

If missing:
> chatter is not configured. Set it up with:
> `curl -fsSL https://raw.githubusercontent.com/rhighs/chatter/main/install.sh | bash -s -- https://github.com/YOUR-ORG/team-skills`

### Find the skill

If not specified, find the most recent:
```bash
ls -t ~/.config/opencode/commands/*.md 2>/dev/null | head -1
ls -t ~/.claude/skills/*/SKILL.md 2>/dev/null | head -1
```

### Run

```bash
chatter sync {skill-file-path}
```

Report the PR URL.

## pull

```bash
chatter pull
```

## status

```bash
cat ~/.config/chatter/team.conf 2>/dev/null && echo "configured" || echo "not configured"
ls ~/.config/opencode/commands/ 2>/dev/null | grep ":"
```
