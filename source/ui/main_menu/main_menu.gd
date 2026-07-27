extends Control

@onready var continue_button: Button = $VBoxContainer/ContinueButton
@onready var new_game_button: Button = $VBoxContainer/NewGameButton
@onready var load_game_button: Button = $VBoxContainer/LoadGameButton
@onready var settings_button: Button = $VBoxContainer/SettingsButton
@onready var gallery_button: Button = $VBoxContainer/GalleryButton
@onready var quit_button: Button = $VBoxContainer/QuitButton
@onready var credits_button: Button = $VBoxContainer/CreditsButton
@onready var title_label: Label = $TitleLabel
@onready var version_label: Label = $VersionLabel

var cheat_input: LineEdit
var cheat_status: Label

func _ready() -> void:
	new_game_button.pressed.connect(_on_new_game)
	load_game_button.pressed.connect(_on_load_game)
	settings_button.pressed.connect(_on_settings)
	gallery_button.pressed.connect(_on_gallery)
	quit_button.pressed.connect(_on_quit)
	continue_button.pressed.connect(_on_continue)
	credits_button.pressed.connect(_on_credits)

	load_game_button.disabled = not SaveManager.has_any_saves()
	continue_button.disabled = not SaveManager.has_any_saves()

	version_label.text = "v1.0.0"
	AudioManager.play_bgm("main_menu")
	_apply_safe_area()
	_setup_cheat_input()
	title_label.gui_input.connect(_on_title_tapped)

func _apply_safe_area() -> void:
	var safe := DisplayServer.get_display_safe_area()
	var viewport_size := get_viewport().get_visible_rect().size
	var margin_top := int(safe.position.y)
	var margin_bottom := int(viewport_size.y - safe.end.y)
	var title: Label = get_node_or_null("TitleLabel")
	if title:
		title.offset_top = max(margin_top + 60, title.offset_top)
	version_label.offset_bottom = -max(margin_bottom + 10, 30)

func _setup_cheat_input() -> void:
	cheat_input = LineEdit.new()
	cheat_input.placeholder_text = "Enter cheat code..."
	cheat_input.visible = false
	cheat_input.custom_minimum_size = Vector2(400, 48)
	cheat_input.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	cheat_input.expand_to_text_length = false
	cheat_input.max_length = 30
	cheat_input.text_submitted.connect(_on_cheat_submitted)
	cheat_input.focus_mode = Control.FOCUS_ALL
	add_child(cheat_input)

	cheat_status = Label.new()
	cheat_status.text = ""
	cheat_status.visible = false
	cheat_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cheat_status.add_theme_font_size_override("font_size", 18)
	cheat_status.custom_minimum_size = Vector2(400, 30)
	cheat_status.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	add_child(cheat_status)

	cheat_input.anchors_preset = Control.PRESET_CENTER
	cheat_input.offset_top = 50
	cheat_input.offset_bottom = 98
	cheat_status.anchors_preset = Control.PRESET_CENTER
	cheat_status.offset_top = 100
	cheat_status.offset_bottom = 130

func _on_title_tapped(event: InputEvent) -> void:
	var is_press := false
	if event is InputEventMouseButton and event.pressed:
		is_press = true
	elif event is InputEventScreenTouch and event.pressed:
		is_press = true
	if is_press:
		cheat_input.visible = not cheat_input.visible
		cheat_status.visible = false
		if cheat_input.visible:
			cheat_input.grab_focus()

func _on_cheat_submitted(text: String) -> void:
	var code := text.strip_edges().to_lower()
	cheat_input.text = ""

	if code in CheatManager.cheats:
		CheatManager.cheats[code].call()
		cheat_status.text = "Cheat activated: %s" % code
		cheat_status.add_theme_color_override("font_color", Color.GREEN)
	else:
		cheat_status.text = "Unknown code: %s" % code
		cheat_status.add_theme_color_override("font_color", Color.RED)

	cheat_status.visible = true
	cheat_input.visible = false

func _on_new_game() -> void:
	GameState.reset_state()
	AffectionManager.characters.clear()
	SceneManager.change_scene("res://source/scenes/gameplay.tscn")

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

func _on_credits() -> void:
	SceneManager.push_scene("res://source/ui/credits/credits_screen.tscn")
