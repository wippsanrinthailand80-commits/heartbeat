# Copyright (c) 2025 wippsanrinthailand80-commits. All Rights Reserved.
# Unauthorized copying, modification, distribution, or reproduction is strictly prohibited.
extends Control

@onready var cg_texture: TextureRect = $CGTexture
@onready var title_label: Label = $Overlay/VBox/TitleLabel
@onready var desc_label: Label = $Overlay/VBox/DescLabel
@onready var ending_id_label: Label = $Overlay/VBox/EndingIDLabel
@onready var menu_button: Button = $Overlay/VBox/MenuButton
@onready var overlay: ColorRect = $Overlay
@onready var cg_fade: ColorRect = $CGFade

const ENDINGS_DATA_PATH := "res://data/endings.json"

func _ready() -> void:
	menu_button.pressed.connect(_on_menu_pressed)
	menu_button.visible = false
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cg_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var character_id = GameState.last_ending_character
	var ending_id = GameState.last_ending_id
	if not ending_id.is_empty():
		_setup_ending(character_id, ending_id)

func _setup_ending(character_id: String, ending_id: String) -> void:
	var config = _load_endings_config()
	var all_ending_info: Dictionary = config.get("ending_info", {})
	var ending_data: Dictionary = all_ending_info.get(ending_id, {})

	var title_text = ending_data.get("title", _format_ending_title(ending_id))
	var desc_text = ending_data.get("description", "")
	var image_path = ending_data.get("image", "")

	title_label.text = title_text
	desc_label.text = desc_text
	ending_id_label.text = ""

	if image_path != "" and ResourceLoader.exists(image_path):
		var tex = load(image_path)
		cg_texture.texture = tex
		cg_texture.visible = true
	else:
		cg_texture.visible = false
		_show_fallback_background()

	await _play_ending_animation()

func _play_ending_animation() -> void:
	cg_fade.color = Color(0, 0, 0, 1)
	cg_fade.visible = true
	overlay.modulate.a = 0.0

	var tween := create_tween()
	tween.set_parallel(true)

	if cg_texture.visible:
		cg_texture.modulate.a = 0.0
		tween.tween_property(cg_texture, "modulate:a", 1.0, 2.0).set_ease(Tween.EASE_OUT)
		tween.tween_property(cg_fade, "color:a", 0.0, 2.0).set_ease(Tween.EASE_OUT)

	tween.chain().tween_interval(1.5)
	tween.tween_property(overlay, "modulate:a", 1.0, 1.0).set_ease(Tween.EASE_OUT)

	await tween.finished

	menu_button.visible = true

func _show_fallback_background() -> void:
	cg_texture.visible = true
	cg_texture.texture = null
	cg_texture.color = Color(0.05, 0.05, 0.12, 1)

func _format_ending_title(ending_id: String) -> String:
	var words = ending_id.replace("_", " ").split(" ")
	var result := ""
	for word in words:
		if word.length() > 0:
			result += word[0].to_upper() + word.substr(1) + " "
	return result.strip_edges()

func _load_endings_config() -> Dictionary:
	var file := FileAccess.open(ENDINGS_DATA_PATH, FileAccess.READ)
	if file == null:
		return {}
	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK:
		return {}
	if json.data is Dictionary:
		return json.data
	return {}

func _on_menu_pressed() -> void:
	SceneManager.change_scene("res://source/scenes/main.tscn")
