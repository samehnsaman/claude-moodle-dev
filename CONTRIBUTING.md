# Contributing to moodle-dev

Thanks for helping improve the Moodle development toolkit and its assistant adapters.

## Ways to contribute

- **Add a skill** — covers a Moodle area not yet handled (e.g., `moodle-h5p`, `moodle-lti`, `moodle-analytics`)
- **Add a workflow** — add a reusable skill, Claude slash command, or both for a common workflow
- **Add a specialist** — add Claude agent instructions and a Codex skill adaptation where useful
- **Improve existing skills** — tighter examples, fix Moodle-version differences, link better docs
- **Report a gap** — open an issue with a prompt Claude got wrong

## Project layout

```
.claude-plugin/         # Claude Code plugin + marketplace manifests
skills/<name>/SKILL.md  # canonical reusable skill sources
commands/<name>.md      # /<name> slash commands
agents/<name>.md        # invocable subagents
adapters/codex/         # Codex plugin package and converted skills
```

## Add a skill

Create `skills/<kebab-name>/SKILL.md`:

```markdown
---
name: <kebab-name>
description: Use when <trigger>. Covers <list of topics>. Skip when <negative trigger>.
---

# <Title>

## Overview
1-2 sentences on what this is.

## When to Use
- Bullet list of trigger scenarios
- **Skip when:** <negative trigger>

## <Sections covering the substance>

## References
- https://moodledev.io/...
```

Rules:
- `description` is used for skill discovery — be specific about task triggers
- Lead with `When to Use` so the activation contract is clear
- Show real Moodle code (not pseudo-code), include version notes (`Moodle 4.4+:`)
- Link `moodledev.io` over wiki / outdated sources
- Cover **common mistakes** in a table — high signal for review
- Keep under ~300 lines; split into multiple skills if larger

## Add a slash command

Create `commands/<kebab-name>.md`:

```markdown
---
name: <kebab-name>
description: One line shown in /help
argument-hint: "[optional args]"
---

Instructions to Claude. Use $ARGUMENTS for the user's input.
```

## Add a subagent

Create `agents/<kebab-name>.md`:

```markdown
---
name: <kebab-name>
description: When to invoke this agent.
tools: Read, Grep, Glob, Bash
---

System prompt for the agent.
```

## PR checklist

- [ ] New/changed files use kebab-case names
- [ ] Frontmatter `name` matches directory/filename
- [ ] `description` clearly states activation triggers
- [ ] Code samples are valid Moodle (no PHP syntax errors)
- [ ] Links go to `moodledev.io` where possible
- [ ] `CHANGELOG.md` updated under `## [Unreleased]`
- [ ] `plugin.json` + `marketplace.json` version bumped if user-facing change
- [ ] Lint workflow passes (JSON valid, frontmatter present)

## Versioning

Semver:
- **patch** — typo, doc tweak, link fix
- **minor** — new skill / command / agent, new section
- **major** — breaking rename / removal

Bump in three places: `plugin.json`, `marketplace.json` (`plugins[].version`), `CHANGELOG.md`.

## Testing locally

Structural checks (fast, run before commit):

```
tests/run.sh
python3 -m unittest tests.test_build_adapters
```

End-to-end check with Claude Code:

```
/plugin marketplace add /absolute/path/to/claude-moodle-dev
/plugin install moodle-dev@moodle-dev
```

Then prompt Claude with a Moodle task and confirm the right skill activates (`/skills` to list active skills).

For Codex, run `./install.sh codex --dest <moodle-checkout>` and start a session in that checkout. Confirm `.agents/skills/moodle-plugin-development/SKILL.md` is present and try an example request from `EXAMPLES.md`. Regenerate adapters with `python3 scripts/build-adapters.py` before committing source changes.

## Adding a new adapter

See [docs/ADAPTER_AUTHORING.md](docs/ADAPTER_AUTHORING.md) for how to support a new AI assistant.

## Security

Vulnerabilities? See [SECURITY.md](SECURITY.md) — do **not** open a public issue.

## Questions

Open a [discussion](https://github.com/SaadRahman01/claude-moodle-dev/discussions) or ping in an issue.
