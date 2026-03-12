# CircleGame — Agent Guide

## What This Is

A 2D arcade jumping game ("1shot") built in Godot 4.5. A spinning circular spawner throws obstacles at the player, who jumps and dodges to score points. Deployed to GitHub Pages automatically on push to master.

## Tech Stack

- **Engine:** Godot 4.5 (GL Compatibility renderer)
- **Language:** GDScript 2.0
- **Shader:** GLSL (background vortex effect)
- **CI/CD:** GitHub Actions using `barichello/godot-ci:4.5`
- **Targets:** Web (HTML5), Windows Desktop

## Project Structure

```
circlegame/
├── project.godot          # Engine config (720x720, main scene: node.tscn)
├── export_presets.cfg     # Export targets (Web, Windows)
├── node.tscn              # Main scene — composes world + UI
├── root.gd                # Game controller: scoring, difficulty, shader params
├── player.gd              # Player: jumping, slamming, collision, sprite stretch
├── spawner.gd             # Obstacle spawner: 16-slot circular layout, rotation
├── score.gd               # Score UI: display, animations, color effects
├── game_over.gd           # Game over overlay and restart
├── cactus.gd / bird.gd   # Deadly obstacles (30 pts each)
├── spring.gd              # Bouncy obstacle (50 pts, boosts player)
├── background.gdshader    # Animated vortex with FBM noise + spiral arms
├── *.tscn                 # Scene files for player, cactus, spring, bird
├── cat.png / cactus.png / spring.png  # Sprites
└── .github/workflows/deploy.yml       # CI/CD pipeline
```

## Key Mechanics

- **Scoring:** Dual system — `potscore` (tentative, accumulated in air) and `score` (finalized on landing). Distance scoring: `potscore += rotations * 25`.
- **Difficulty:** Spawner rotation speed scales with score and elapsed time: `rot_speed = 1.0 + potscore * intensity + (time / 100)`.
- **Spawner:** 16 slots on a circle (radius 320px, center at 360,360). Smart placement prevents 3+ consecutive identical obstacles.
- **Player:** Gravity-based physics. Jump on tap/space, slam down while airborne. Two collision shapes swap based on direction.
- **Background shader:** Vortex with 3 spiral arms, 6-color palette, vibrance tied to gameplay intensity.

## How to Build & Run

This project runs on a headless server with no display driver. All Godot commands must use `--headless`.

| Task | Command |
|------|---------|
| Validate scripts | `godot --headless --quit 2>&1` |
| Export Web | `godot --headless --export-release "Web" build/index.html` |
| Export Windows | `godot --headless --export-release "Windows Desktop" export/1shot.exe` |

You cannot open the editor or play the game — there is no GUI. CI automatically builds and deploys the web export on push to `master`.

## Conventions

- Scene composition: each entity (player, obstacle) is a separate `.tscn` with its own script.
- Signals used for inter-system communication (e.g., player death triggers game over).
- Window is 720x720 (1:1 aspect ratio).
- All game logic runs in GDScript `_process()` and `_physics_process()` callbacks.
- Floor is at Y=678 in world space.

## Debugging

To check for GDScript parse errors and runtime errors, run:

```bash
godot --headless --quit 2>&1
```

This launches the project headlessly and immediately quits, printing any script errors to stdout/stderr. Use this after making changes to validate scripts before committing.

**Note:** A single parse error (e.g., in `root.gd`) can cause cascading runtime errors in other scripts that depend on the broken script's properties. Always fix the earliest reported error first.
