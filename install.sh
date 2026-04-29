#!/bin/bash
set -e

TEAM_REPO_URL="$1"
TEAM_REPO_PATH="${2:-$HOME/.local/share/chatter/team-skills}"
BIN_DIR="$HOME/.local/bin"
BASE_URL="https://raw.githubusercontent.com/rhighs/chatter/main"
OPENCODE_COMMANDS="$HOME/.config/opencode/commands"
CLAUDE_SKILLS="$HOME/.claude/skills/chatter"

if [ -z "$TEAM_REPO_URL" ]; then
  echo "Usage: install.sh <team-repo-url>"
  echo "Example: install.sh https://github.com/your-org/team-skills"
  exit 1
fi

echo "Setting up chatter..."
echo ""

# Clone or pull team repo
if [ -d "$TEAM_REPO_PATH/.git" ]; then
  git -C "$TEAM_REPO_PATH" pull --quiet && echo "✓ team repo updated"
else
  git clone "$TEAM_REPO_URL" "$TEAM_REPO_PATH" --quiet && echo "✓ team repo cloned"
fi

# Write config
mkdir -p "$HOME/.config/chatter"
cat > "$HOME/.config/chatter/team.conf" << CONF
TEAM_REPO_PATH="$TEAM_REPO_PATH"
TEAM_REPO_REMOTE="$TEAM_REPO_URL"
CONF
echo "✓ config written to ~/.config/chatter/team.conf"

# Download scripts
curl -fsSL "$BASE_URL/scripts/sync.sh" -o "$HOME/.config/chatter/sync.sh" && chmod +x "$HOME/.config/chatter/sync.sh"
curl -fsSL "$BASE_URL/scripts/pull.sh" -o "$HOME/.config/chatter/pull.sh" && chmod +x "$HOME/.config/chatter/pull.sh"
echo "✓ scripts installed"

# Install chatter CLI binary
mkdir -p "$BIN_DIR"
cat > "$BIN_DIR/chatter" << 'BIN'
#!/bin/bash
CMD="$1"; shift
case "$CMD" in
  sync)   ~/.config/chatter/sync.sh "$@" ;;
  pull)   ~/.config/chatter/pull.sh "$@" ;;
  status) cat ~/.config/chatter/team.conf 2>/dev/null && echo "configured" || echo "not configured" ;;
  *)      echo "Usage: chatter <sync|pull|status>"; exit 1 ;;
esac
BIN
chmod +x "$BIN_DIR/chatter"
echo "✓ chatter CLI installed to $BIN_DIR/chatter"

# Install AI skill for opencode
if [ -d "$OPENCODE_COMMANDS" ] || command -v opencode &>/dev/null; then
  mkdir -p "$OPENCODE_COMMANDS"
  curl -fsSL "$BASE_URL/opencode-command/chatter.md" -o "$OPENCODE_COMMANDS/chatter.md"
  echo "✓ opencode skill installed"
fi

# Install AI skill for Claude Code
if [ -d "$HOME/.claude" ] || command -v claude &>/dev/null; then
  mkdir -p "$CLAUDE_SKILLS"
  curl -fsSL "$BASE_URL/claude-skill/SKILL.md" -o "$CLAUDE_SKILLS/SKILL.md"
  echo "✓ Claude Code skill installed"
fi

# Stow existing team skills
if command -v stow &>/dev/null; then
  [ -d "$TEAM_REPO_PATH/opencode" ] && stow --dir="$TEAM_REPO_PATH" opencode --target="$OPENCODE_COMMANDS" --restow 2>/dev/null && echo "✓ team opencode skills linked"
  [ -d "$TEAM_REPO_PATH/claude"   ] && mkdir -p "$HOME/.claude/skills" && stow --dir="$TEAM_REPO_PATH" claude --target="$HOME/.claude/skills" --restow 2>/dev/null && echo "✓ team Claude Code skills linked"
else
  echo "⚠ stow not found — install it to auto-link team skills (brew install stow)"
fi

echo ""
echo "Done. chatter is ready."
echo ""
echo "  chatter sync <skill>   push a skill to the team + open PR"
echo "  chatter pull           pull latest team skills"
echo "  chatter status         check configuration"
echo ""
echo "The AI can also use it directly — /chatter is now available in opencode and Claude Code."
