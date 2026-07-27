extends Control

@onready var continue_button: Button = $VBoxContainer/ContinueButton
@onready var new_game_button: Button = $VBoxContainer/NewGameButton
@onready var load_game_button: Button = $VBoxContainer/LoadGameButton
@onready var settings_button: Button = $VBoxContainer/SettingsButton
@onready var gallery_button: Button = $VBoxContainer/GalleryButton
@onready var quit_button: Button = $VBoxContainer/QuitButton
@onready var title_label: Label = $TitleLabel
@onready var version_label: Label = $VersionLabel

func _ready() -> void:
	new_game_button.pressed.connect(_on_new_game)
	load_game_button.pressed.connect(_on_load_game)
	settings_button.pressed.connect(_on_settings)
	gallery_button.pressed.connect(_on_gallery)
	quit_button.pressed.connect(_on_quit)
	continue_button.pressed.connect(_on_continue)

	load_game_button.disabled = not SaveManager.has_any_saves()
	continue_button.disabled = not SaveManager.has_any_saves()

	version_label.text = "v1.0.0"
	AudioManager.play_bgm("main_menu")

func _on_new_game() -> void:
	GameState.reset_state()
	AffectionManager.characters.clear()
	SceneManager.change_scene("res://source/scenes/locations/prologue.tscn")

func _on_continue() -> void:
	if SaveManager.quick_load():
		SceneManager.change_scene("res://source/scenes/gameplay.tscn")

func _on_load_game() -> void:
	SceneManager.push_scene("res://source/ui/save_load_menu/save_load_menu.tscn")

func _on_settings() -> void:
	SceneManager.push_scene("res://source/ui/settings/settings_menu.tscn")

func _on_gallery() -> void:
	SceneManager.push_scene("res://source/features/gallery/gallery_scene.tscn")

func _on_quit() -> void:
	get_tree().quit()
