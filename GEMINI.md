# Photo Push — Project Instructions

## Commit Conventions

All commits must follow the [Conventional Commits](https://www.conventionalcommits.org/) specification and **must always be written in English**.

### Format

```text
<type>(<scope>): <short summary in English>

[optional body in English]

assisted-by: <tool-name>, <model-name>
```

Allowed types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`.

### AI Assistant Attribution

Any commit generated or prepared with the assistance of an AI agent/tool must include the following trailer in the commit footer:

```text
assisted-by: <tool-name>, <model-name>
```

- `<tool-name>`: in lowercase or kebab-case (e.g. `gemini-cli`, `cursor`, `claude-code`).
- `<model-name>`: specific model identifier (e.g. `gemini-2.5-pro`, `claude-3-7-sonnet`).

### Example

```gitcommit
feat(albums): enforce case-insensitive unique album names

assisted-by: gemini-cli, gemini-2.5-pro
```

See [AGENTS.md](./AGENTS.md) for shared instructions across all AI assistants.
