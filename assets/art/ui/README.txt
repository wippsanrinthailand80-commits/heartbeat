# UI Assets

Drop your PNG files here to customize the game's UI.

## Directory Structure

- `backgrounds/` — Screen background images (main menu, settings, etc.)
- `buttons/` — Button textures (normal, hover, pressed states)
- `panels/` — Panel/dialogue box background textures
- `icons/` — Icon images for HUD buttons
- `fonts/` — Custom font files (.ttf, .otf)

## How to Use

1. Drop your PNG/image files in the matching subdirectory
2. Open `data/ui_theme.json` in the project root
3. Set the `texture` path to your file, e.g.:
   `"texture": "res://assets/art/ui/backgrounds/my_background.png"`
4. Leave `texture` empty to use the solid color fallback instead
5. Restart the game to see changes

## Naming Convention

Use descriptive names like:
- `main_menu_bg.png` for backgrounds
- `btn_normal.png`, `btn_hover.png`, `btn_pressed.png` for buttons
- `dialogue_panel.png` for the dialogue box

## Notes

- All paths must start with `res://`
- PNG files are imported automatically by Godot
- Colors use RGBA format with values 0.0 to 1.0
- Font sizes are in pixels
