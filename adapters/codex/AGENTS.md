# Moodle plugin development with Codex

This project provides reusable Moodle development skills in `skills/`.
For Moodle work, identify and use the relevant `moodle-*` skill from
`.agents/skills/` when installed, or from `adapters/codex/skills/` in this repository.

Follow the target Moodle version and the conventions already present in the plugin.
Prefer official Moodle developer documentation when a version-specific detail is
unclear. Preserve existing files and user changes; do not replace an existing plugin
implementation with a scaffold. Run the checks available in the Moodle checkout and
report checks that could not be run.

The former Claude slash-command workflows are available as on-demand skills such as
`moodle-new-plugin`, `moodle-security-review`, and `moodle-bump-version`. The former
specialist agents are available as `moodle-scaffolder` and `moodle-reviewer` skills.
