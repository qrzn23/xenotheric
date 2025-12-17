# AGENTS.md

This file defines how **Codex-powered agents** should interact with this repository.
It exists to reduce ambiguity, prevent architectural drift, and keep automated changes aligned with the project’s design constraints.

Agents are expected to **follow these rules strictly**. If a requested change conflicts with them, prefer refusing or proposing an alternative over silently violating constraints.

---

## Project Overview

This repository contains a **2D Metroid-style game built with Godot 4** (Xenotheric).
The project prioritizes:

* deterministic movement and combat
* explicit state machines
* modular, scene-based composition
* long-term maintainability over short-term convenience

Agents should optimize for **clarity, predictability, and refactorability**.

---

## Repository Structure (Preferred)

Agents should align new work to this layout:

```
res://
  scenes/        # Playable scenes, UI, level chunks
  scripts/
    core/        # State machines, enums, config, save data
    actors/      # Player, enemies, bosses
    systems/     # Camera, combat, traversal, inventory
  assets/        # Art, audio, fonts (no logic)
  addons/        # Third-party plugins (GUT, etc.)
  tests/         # GUT tests and scene fixtures
  builds/        # Exported artifacts (gitignored)
```

Rules:

* Scene files and their primary scripts must live together (or be colocated in a clear actor/system folder).
* Do not introduce new top-level folders without justification.
* Autoloads are allowed only for small, global services (state, events, save data).
* Gameplay behavior belongs in scenes and scripts, not editor-only configuration.

### Transition Notes

The repo currently contains legacy groupings such as `scripts/player`, `scripts/enemies`, and `scripts/props`.
Do not churn existing paths purely for reorganization; prefer migrating only when touching a feature.

---

## Gameplay Architecture Rules

### State & Control Flow

* Player and enemy behavior must use explicit **state machines**.
* Do not introduce ad-hoc boolean flags to replace states.
* State transitions should be centralized and traceable.
* Exactly one node owns movement authority at any time.

### Combat Model

* Hitboxes and hurtboxes must be separate nodes.
* Damage resolution must occur in a single, well-defined location.
* Avoid applying damage by directly calling methods across the scene tree; prefer signals/events routed through a combat resolver/system.

### Camera Ownership

* Camera behavior belongs to a dedicated camera system.
* Gameplay nodes may emit requests or signals but must not control the camera directly.

---

## Coding Standards for Agents

Agents must generate code that follows these conventions:

* Godot 4 GDScript
* 4-space indentation (no tabs; avoid mixing indentation styles in a single file)
* Typed variables where practical
* PascalCase: scenes and script classes
* snake_case: variables and functions
* ALL_CAPS: constants

Additional constraints:

* Node references must be cached in `_ready()`.
* Avoid hard-coded node paths (e.g. `$"../.."`); prefer exported `NodePath` or dependency injection.
* Signals must be explicit and semantically named.
* Prefer data-driven logic over deep conditional chains.

---

## Performance & Determinism Constraints

Agents must avoid introducing nondeterministic or frame-dependent behavior.

Rules:

* No memory allocations per frame in `_process()` or `_physics_process()`.
* Physics-related logic belongs exclusively in `_physics_process()`.
* Prefer timers and state transitions over raw `delta` arithmetic.
* Avoid per-frame scene traversal (`get_tree()`, `find_node()`, etc.).

If a change causes jitter, drift, or timing instability, it is considered incorrect.

---

## Testing Expectations

Agents are expected to:

* Add or update **GUT** tests when modifying behavior.
* Place tests under `tests/` mirroring the scene or system structure.
* Name test files `test_<feature>.gd`.
* Name test methods `test_<expected_behavior>()`.

For interaction-heavy features:

* Use minimal scene fixtures.
* Simulate input and signals programmatically.
* Do not rely on editor interaction for validation.

Bug fixes should include regression tests whenever feasible.

---

## Build & Validation Commands (Agent-Aware)

Agents may assume the following commands are authoritative:

* Syntax and dependency validation:

  ```
  godot --path . --headless --check-only
  ```

* Run tests (prefer clean exit):

  ```
  godot --path . --headless -s res://addons/gut/gut_cmdln.gd -gdir=res://tests -gexit --rendering-driver opengl3
  ```

* Minimal CI sanity check:

  ```
  godot --path . --headless --quit-after 1
  ```

Agents should not propose changes that break these checks.

---

## Version Control Discipline

When generating commits or commit messages, agents must follow **Conventional Commits**:

* `feat: add wall jump`
* `fix: resolve enemy knockback drift`
* `test: add dash cooldown spec`

Changes should be:

* focused on a single concern
* minimally scoped
* accompanied by tests where appropriate

Large, multi-system refactors should be proposed, not executed blindly.

---

## Security & Asset Handling

Agents must not:

* introduce secrets or credentials
* commit exported builds or large binaries
* modify `.import/` or generated files

Third-party assets must be credited in `assets/README.md`.

---

## Agent Behavior Contract

Agents operating in this repository should:

* preserve architectural intent
* prefer refusal over silent rule-breaking
* explain trade-offs when constraints limit a solution

This project values **stable systems over clever hacks**.
If a proposed change increases entropy, it is not an improvement.
