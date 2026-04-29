#!/bin/bash
# chatter sync — copy a skill to the team repo and open a PR
set -e

SKILL_FILE="$1"
CONF="$HOME/.config/chatter/team.conf"

if [ ! -f "$CONF" ]; then
  echo "No team config. Run: curl -fsSL https://raw.githubusercontent.com/rhighs/chatter/main/install.sh | bash -s -- <repo-url>" >&2
  exit 1
fi
source "$CONF"

if [ ! -f "$SKILL_FILE" ]; then
  echo "Skill file not found: $SKILL_FILE" >&2; exit 1
fi

SKILL_NAME=$(basename "$SKILL_FILE" .md)
BRANCH="chatter/${SKILL_NAME}-$(date +%Y%m%d-%H%M%S)"

cd "$TEAM_REPO_PATH"
git fetch origin --quiet
git checkout -b "$BRANCH" origin/main --quiet

mkdir -p "opencode" "claude/${SKILL_NAME}"

# opencode version (plain markdown)
cp "$SKILL_FILE" "opencode/${SKILL_NAME}.md"

# Claude Code version (add required SKILL.md frontmatter)
# Extract body (everything after the closing --- of frontmatter)
# If no frontmatter, use the whole file
if head -1 "$SKILL_FILE" | grep -q '^---$'; then
  BODY=$(awk 'BEGIN{n=0} /^---$/{n++; next} n>=2{print}' "$SKILL_FILE")
else
  BODY=$(cat "$SKILL_FILE")
fi

# Extract description from frontmatter (multiline YAML scalar)
DESC=$(awk '
  BEGIN{in_fm=0; in_desc=0}
  /^---$/ {in_fm++; next}
  in_fm==1 && /^description:/ {
    sub(/^description:[[:space:]]*/, "")
    if ($0 != "" && $0 != "|") { print; in_desc=0; next }
    in_desc=1; next
  }
  in_fm==1 && in_desc && /^[[:space:]]/ { sub(/^[[:space:]]+/, ""); print; next }
  in_fm==1 && in_desc { in_desc=0 }
  in_fm>=2 {exit}
' "$SKILL_FILE")

cat > "claude/${SKILL_NAME}/SKILL.md" << SKILLEOF
---
name: ${SKILL_NAME}
description: |
  ${DESC:-See ${SKILL_NAME}}
version: 1.0.0
---

${BODY}
SKILLEOF

git add "opencode/${SKILL_NAME}.md" "claude/${SKILL_NAME}/SKILL.md"
git commit -m "skill: ${SKILL_NAME}"
git push origin "$BRANCH" --quiet

gh pr create \
  --title "skill: ${SKILL_NAME}" \
  --body "Synced by chatter.

**Install after merge:**
\`\`\`bash
chatter pull
\`\`\`" \
  --head "$BRANCH" \
  --base main

echo "PR opened: ${SKILL_NAME}"
