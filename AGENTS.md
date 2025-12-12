Repository Guidelines

## Project Structure & Module Organization
Use a Godot-friendly layout: keep playable scenes and UI under `scenes/`, core gameplay scripts under `scripts/`, shared data (state, config, enums) in `scripts/core`, art/audio in `assets/`, plugins in `addons/`, automated checks in `tests/`, and export artifacts in `builds/`. Group related scene+script pairs in their own subfolders and prefer lightweight autoloads for global state.

## Build, Test, and Development Commands
- `godot4 --path .` opens the project; run the main scene to play locally.
- `godot4 --path . --headless --check-only` validates GDScript syntax and catches missing dependencies; run before commits.
- `godot4 --path . --headless -s res://addons/gut/gut_cmdln.gd -gdir=res://tests` executes GUT tests (ensure the addon is installed and tests live in `tests/`).
- `godot4 --path . --export-release "Linux/X11" builds/MetroidClone.x86_64` exports a release build; adjust the preset name/output path to match `export_presets.cfg`.

## Coding Style & Naming Conventions
Use GDScript 4 with 4-space indentation and typed declarations. Name scenes and script classes in PascalCase, functions and variables in snake_case, and constants in ALL_CAPS. Keep node names stable and signals explicit; avoid magic node paths by caching references in `_ready()`. Prefer composition (child nodes) over deep inheritance for gameplay entities.

## Testing Guidelines
Favor GUT for unit/integration coverage; mirror the scene tree in `tests/` for discoverability. Name files `test_<feature>.gd` and methods `test_<behavior>()`. Add regression tests for bug fixes and run the headless GUT command before raising a PR. For complex interactions, add minimal scene fixtures that simulate input rather than relying on the editor.

## Commit & Pull Request Guidelines
Use Conventional Commits (e.g., `feat: add dash cooldown`, `fix: resolve camera jitter`, `test: add boss ai spec`). Keep messages focused on behavior change and mention relevant scene/script paths. PRs should include a short summary, linked issues, risk/rollback notes, and screenshots or GIFs for gameplay/UI changes. Keep PRs small and scoped to a single concern.

## Security & Configuration Tips
Do not commit secrets, platform exports, or large binary imports; ensure generated `.import/` assets stay gitignored. Credit third-party art/audio in an `assets/README.md` entry. Run `godot4 --path . --headless --quit-after 1` in CI to catch missing resources or bad project settings early.
