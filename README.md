# Dating Sim Engine

A full-fledged dating simulation game built with Godot 4.

## Features

- **Dialogue System** — Branching dialogue with choices, conditions, and effects
- **Affection System** — Multi-axis relationship tracking (trust, comfort, attraction, respect)
- **Save/Load** — 10 save slots with versioned saves, quick save/load
- **CG Gallery** — Unlockable gallery with scene replay
- **Audio** — BGM, SFX, and voice support with crossfading
- **Route Manager** — Flag-based branching, multiple endings per character
- **Minigames** — Extensible minigame system
- **Cross-Platform** — Exports to Desktop (Windows, Linux), Web (HTML5), and Android
- **Auto/Skip** — Auto-advance and skip modes for dialogue
- **Backlog** — Scrollable dialogue history
- **Pause Menu** — Full pause menu with settings access

## Project Structure

```
dating-sim/
├── addons/              # Third-party plugins
├── assets/              # Raw art, audio, fonts (GDIgnored)
│   ├── art/
│   │   ├── characters/  # Character sprites per character/emotion
│   │   ├── backgrounds/ # Scene backgrounds
│   │   └── ui/          # UI sprites and icons
│   └── audio/
│       ├── music/       # BGM tracks
│       ├── sfx/         # Sound effects
│       └── voice/       # Per-character voice lines
├── data/                # Game data (narrative, configs)
│   ├── dialogues/       # Dialogue JSON files
│   ├── characters/      # Character profile JSONs
│   ├── items/           # Item definitions
│   └── config/          # Game settings
├── source/              # Godot scenes and scripts
│   ├── autoload/        # Global singletons
│   ├── features/        # Feature modules
│   │   ├── dialogue/    # Dialogue engine
│   │   ├── characters/  # Character management
│   │   ├── romance/     # Affection & route systems
│   │   ├── gallery/     # CG gallery
│   │   ├── time/        # In-game calendar
│   │   └── minigames/   # Minigame framework
│   ├── ui/              # All UI scenes and scripts
│   ├── scenes/          # Gameplay scenes
│   └── shaders/         # Custom shaders
└── project.godot
```

## Setup

1. Install Godot 4.3+
2. Open `project.godot` in the Godot editor
3. Place your art assets in `assets/`
4. Add character profiles in `data/characters/`
5. Write dialogue in `data/dialogues/`
6. Hit Play!

## Adding Characters

Create a JSON file in `data/characters/`:

```json
{
  "id": "character_id",
  "display_name": "Character Name",
  "color": "#ff6b9d",
  "portraits": {
    "neutral": "res://assets/art/characters/id/neutral.png",
    "happy": "res://assets/art/characters/id/happy.png"
  }
}
```

## Writing Dialogue

Create JSON files in `data/dialogues/chapter_XX/`:

```json
{
  "id": "scene_id",
  "start_line": "start",
  "lines": [
    {
      "id": "start",
      "speaker": "character_id",
      "text": "Hello there!",
      "emotion": "happy",
      "next": "next_line_id",
      "effects": [
        {"type": "affection", "character": "character_id", "axis": "trust", "amount": 5.0}
      ]
    }
  ]
}
```

## Controls

- **Left Click / Space / Enter** — Advance dialogue
- **A** — Toggle auto mode
- **S** — Toggle skip mode
- **H** — Open backlog
- **Esc** — Pause menu / close overlays
- **Ctrl+S** — Quick save
- **Ctrl+L** — Quick load

## Cross-Platform Notes

- Uses **Mobile renderer** for maximum compatibility
- Pure **GDScript** (no GDExtension) for web export support
- Web export requires COOP/COREP headers (itch.io handles this automatically)
- Android requires JDK 17+ and Android SDK

## License

Proprietary — All Rights Reserved. See [LICENSE](LICENSE) for details.
Copyright (c) 2025 wippsanrinthailand80-commits. No part of this project may be
copied, distributed, or modified without written permission.
