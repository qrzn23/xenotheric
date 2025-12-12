# Roadmap

## Now
- Basic player movement, shooting, missiles, morph toggle, and pickups in place.
- Global state via `GameState.gd` with HUD signals wired; GUT installed and one movement test passing.
- Runs on this machine with `--rendering-driver opengl3` (Vulkan not available).
- Inputs mapped: arrows/left stick for move, `Space`/A for jump, `F`/X for fire, `R`/RB for missile, `Shift`/B for dash, `S`/LB for morph, `Esc`/Start for pause.

## Next
- Add more GUT specs mirroring scenes (player abilities, enemy damage, pickups).
- Flesh out player animations/sprites and hurtbox/invuln feedback.
- Populate rooms with more enemy variants and simple hazards.
- Implement pause/menu scene and audio cues for key actions.

## Later
- Save/load of unlocked abilities and progress.
- Export preset verification and CI script to run `--check-only` and GUT.
- Art/audio pass with credits tracked in `assets/README.md`.
