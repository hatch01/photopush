# PhotoPush — Flutter Project Instructions

This project is a standalone, offline-first Flutter mobile application.
It runs 100% offline, without user accounts, without a SQL database, and without a mandatory remote server.

## Architecture & Data Storage

- **Album as unit of storage:** Each album is a directory under the application documents directory:
  - `albums/<AlbumName>/album.json` (model, single source of truth)
  - `albums/<AlbumName>/cover.jpg` (album cover thumbnail)
  - `albums/<AlbumName>/images/` (locally imported/copied photos)
- **Atomic file writes:** All writes to `album.json` write to a temporary file (`album.json.tmp`) first, followed by an atomic rename.
- **Three-tier architecture:**
  - `lib/ui/` (Presentation & Screens)
  - `lib/models/` (Data models, JSON serialization, domain entities)
  - `lib/services/` (Storage, image processing, file management, import/export)
- **Pins:** Pinned coordinates are normalized floats `x, y ∈ [0.0, 1.0]` relative to the source image dimensions.

## Workflow Checklist

Checklist after making changes, in this order:

- `flutter analyze`
- `dart format --output=none --set-exit-if-changed .`
- `flutter test`

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
