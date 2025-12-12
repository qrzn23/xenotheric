# Xenotheric (Godot 4)

Lightweight Metroidvania prototype built with Godot 4. Playable scenes live in `scenes/`, gameplay scripts in `scripts/`, and tests in `tests/` (GUT).

## Run
- Play locally: `godot4 --path .` then run the main scene.
- Syntax check: `godot4 --path . --headless --check-only`
- Tests (GUT): `godot4 --path . --headless -s res://addons/gut/gut_cmdln.gd -gdir=res://tests --rendering-driver opengl3 --quit-after 1`  
  The `--quit-after` timer can print a harmless leak warning.

## Tests in this repo
- `tests/test_game_state.gd`: health/missile signals, clamping, ability unlocks.
- `tests/test_player_movement.gd`: coyote/jump buffers, morph collider/sprite toggling.
- `tests/test_player_abilities.gd`: dash gating, wall jump force needs ability, missile ammo/ability gating, invuln damage cooldown.
- `tests/test_pickups_and_projectiles.gd`: pickups heal/add ammo/unlock, bullets and missiles deal damage and free themselves.
- `tests/test_patroller.gd`: patroller flips direction via `_flip_direction()` and queues free on damage.
