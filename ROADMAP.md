# Roadmap

## Now
- Basic player movement, shooting, missiles, morph toggle, and pickups in place.
- Global state via `GameState.gd` with HUD signals wired; GUT installed with coverage for movement, abilities, pickups, projectiles, and patroller behavior.
- Runs on this machine with `--rendering-driver opengl3` (Vulkan not available).
- Inputs mapped: arrows/left stick for move, `Space`/A for jump, `F`/X for fire, `R`/RB for missile, `Shift`/B for dash, `S`/LB for morph, `Esc`/Start for pause.

## Next
- Flesh out player animations/sprites and hurtbox/invuln feedback.
- Add enemy-to-player contact damage tests/logic and hazards.
- Populate rooms with more enemy variants and simple hazards.
- Implement pause/menu scene and audio cues for key actions.

## Later
- Save/load of unlocked abilities and progress.
- Export preset verification and CI script to run `--check-only` and GUT.
- Art/audio pass with credits tracked in `assets/README.md`.
