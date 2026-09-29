#!/usr/bin/env bash
# moodle-dev installer for assistants without the native Claude plugin.
#
# Usage:
#   ./install.sh <target> [--dest <dir>]
#
# Targets:
#   cursor    -> copies .cursor/ into <dest>
#   copilot   -> copies .github/copilot-instructions.md + chatmodes into <dest>/.github
#   aider     -> copies CONVENTIONS.md (and skills/, commands/) into <dest>
#   continue  -> copies config.yaml + rules + prompts into <dest>/.continue
#   generic   -> writes adapters/generic/PROMPTS.md into <dest>/MOODLE_PROMPTS.md
#   codex     -> installs skills into <dest>/.agents/skills and merges Moodle guidance into AGENTS.md
#
# Default <dest> is the current directory.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"

usage() {
  sed -n '2,15p' "$0"
  exit 1
}

[ $# -ge 1 ] || usage
target="$1"; shift
dest="."

while [ $# -gt 0 ]; do
  case "$1" in
    --dest) dest="$2"; shift 2 ;;
    -h|--help) usage ;;
    *) echo "Unknown arg: $1" >&2; usage ;;
  esac
done

if [ ! -d "$dest" ]; then
  echo "Destination does not exist: $dest" >&2
  exit 1
fi

dest="$(cd "$dest" && pwd)"
echo "» Installing moodle-dev ($target) into $dest"

copy_tree() {
  src="$1"; dst="$2"
  if [ ! -d "$src" ]; then echo "Missing source: $src" >&2; exit 1; fi
  mkdir -p "$dst"
  cp -R "$src"/. "$dst"/
}

case "$target" in
  cursor)
    copy_tree "$ROOT/adapters/cursor/.cursor" "$dest/.cursor"
    echo "Done. Cursor will pick up rules in .cursor/rules/."
    ;;
  copilot)
    copy_tree "$ROOT/adapters/copilot/.github" "$dest/.github"
    echo "Done. Copilot reads .github/copilot-instructions.md per repo."
    ;;
  aider)
    cp "$ROOT/adapters/aider/CONVENTIONS.md" "$dest/CONVENTIONS.md"
    [ -d "$ROOT/adapters/aider/skills" ] && copy_tree "$ROOT/adapters/aider/skills" "$dest/.aider/skills"
    [ -d "$ROOT/adapters/aider/commands" ] && copy_tree "$ROOT/adapters/aider/commands" "$dest/.aider/commands"
    echo "Done. Add to .aider.conf.yml:"
    echo "  read:"
    echo "    - CONVENTIONS.md"
    ;;
  continue)
    copy_tree "$ROOT/adapters/continue" "$dest/.continue"
    echo "Done. Restart Continue to load rules + prompts."
    ;;
  generic)
    cp "$ROOT/adapters/generic/PROMPTS.md" "$dest/MOODLE_PROMPTS.md"
    echo "Done. Paste sections from MOODLE_PROMPTS.md into your assistant's system prompt."
    ;;
  codex)
    copy_tree "$ROOT/adapters/codex/skills" "$dest/.agents/skills"
    python3 - "$dest/AGENTS.md" "$ROOT/adapters/codex/AGENTS.md" <<'PY'
from pathlib import Path
import sys

target, source = map(Path, sys.argv[1:])
begin = "<!-- moodle-dev:begin -->"
end = "<!-- moodle-dev:end -->"
block = f"{begin}\n{source.read_text().strip()}\n{end}"
current = target.read_text() if target.exists() else ""
if begin in current and end in current:
    before, rest = current.split(begin, 1)
    _, after = rest.split(end, 1)
    current = before.rstrip() + "\n\n" + block + after
else:
    current = current.rstrip() + ("\n\n" if current.strip() else "") + block + "\n"
target.write_text(current)
PY
    echo "Done. Codex skills are in .agents/skills/; Moodle instructions were merged into AGENTS.md."
    ;;
  *)
    echo "Unknown target: $target" >&2
    usage
    ;;
esac
