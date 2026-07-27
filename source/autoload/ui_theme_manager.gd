# Copyright (c) 2025 wippsanrinthailand80-commits. All Rights Reserved.
# Unauthorized copying, modification, distribution, or reproduction is strictly prohibited.
extends Node

const CONFIG_PATH := "res://data/ui_theme.json"

var _config: Dictionary = {}
var _theme: Theme = Theme.new()

func _ready() -> void:
	_load_config()
	_build_theme()
	_apply_global_theme()

func _load_config() -> void:
	var file := FileAccess.open(CONFIG_PATH, FileAccess.READ)
	if file == null:
		push_warning("UIThemeManager: No ui_theme.json found, using defaults")
		return
	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK:
		push_warning("UIThemeManager: Failed to parse ui_theme.json")
		return
	if json.data is Dictionary:
		_config = json.data

func _build_theme() -> void:
	_build_button_theme()
	_build_label_theme()
	_build_panel_theme()
	_build_dialogue_theme()
	_build_global_colors()

func _build_button_theme() -> void:
	for btn_type in ["primary", "secondary", "icon"]:
		var btn_config: Dictionary = _config.get("buttons", {}).get(btn_type, {})
		if btn_config.is_empty():
			continue

		var style_normal := StyleBoxFlat.new()
		var style_hover := StyleBoxFlat.new()
		var style_pressed := StyleBoxFlat.new()
		var style_disabled := StyleBoxFlat.new()

		_apply_button_style(style_normal, btn_config, "normal")
		_apply_button_style(style_hover, btn_config, "hover")
		_apply_button_style(style_pressed, btn_config, "pressed")
		_apply_button_style(style_disabled, btn_config, "disabled")

		_theme.set_stylebox("normal", btn_type, style_normal)
		_theme.set_stylebox("hover", btn_type, style_hover)
		_theme.set_stylebox("pressed", btn_type, style_pressed)
		_theme.set_stylebox("disabled", btn_type, style_disabled)

		var font_color = btn_config.get("font_color", [1.0, 1.0, 1.0, 1.0])
		var font_hover = btn_config.get("font_hover_color", [1.0, 0.85, 0.2, 1.0])
		var font_pressed = btn_config.get("font_pressed_color", [0.7, 0.7, 0.7, 1.0])
		var font_disabled = btn_config.get("font_disabled_color", [0.4, 0.4, 0.4, 1.0])

		_theme.set_color("font_color", btn_type, _arr_to_color(font_color))
		_theme.set_color("font_hover_color", btn_type, _arr_to_color(font_hover))
		_theme.set_color("font_pressed_color", btn_type, _arr_to_color(font_pressed))
		_theme.set_color("font_disabled_color", btn_type, _arr_to_color(font_disabled))

func _apply_button_style(style: StyleBoxFlat, config: Dictionary, state: String) -> void:
	var bg_color = config.get("bg_" + state + "_color", config.get("bg_color", [0.15, 0.15, 0.25, 0.8]))
	var border_color = config.get("border_color", [0.3, 0.3, 0.5, 0.6])
	var corner = config.get("corner_radius", 8)

	style.bg_color = _arr_to_color(bg_color)
	style.border_color = _arr_to_color(border_color)
	style.set_border_width_all(2)
	style.set_corner_radius_all(corner)
	style.set_content_margin_all(16)

	var tex_path = config.get(state + "_texture", "")
	if tex_path != "" and ResourceLoader.exists(tex_path):
		style.bg_texture = load(tex_path)

func _build_label_theme() -> void:
	var sizes: Dictionary = _config.get("fonts", {}).get("sizes", {})
	for size_name in sizes:
		var size_val = sizes[size_name]
		if size_val is int or size_val is float:
			_theme.set_font_size(size_name, "Label", int(size_val))
			_theme.set_font_size(size_name, "Button", int(size_val))

	var dialogue_config: Dictionary = _config.get("dialogue", {})
	var speaker_color = dialogue_config.get("speaker_font_color", [0.4, 0.8, 1.0, 1.0])
	var text_color = dialogue_config.get("text_font_color", [0.95, 0.95, 0.95, 1.0])
	_theme.set_color("font_color", "SpeakerLabel", _arr_to_color(speaker_color))
	_theme.set_color("font_color", "DialogueLabel", _arr_to_color(text_color))

func _build_panel_theme() -> void:
	var dialogue_config: Dictionary = _config.get("dialogue", {})
	var panel_color = dialogue_config.get("panel_color", [0.05, 0.05, 0.1, 0.92])
	var border_color = dialogue_config.get("panel_border_color", [0.3, 0.3, 0.5, 0.5])
	var corner = dialogue_config.get("panel_corner_radius", 12)

	var style := StyleBoxFlat.new()
	style.bg_color = _arr_to_color(panel_color)
	style.border_color = _arr_to_color(border_color)
	style.set_border_width_all(2)
	style.set_corner_radius_all(corner)
	style.set_content_margin_all(20)
	_theme.set_stylebox("panel", "PanelContainer", style)

func _build_dialogue_theme() -> void:
	pass

func _build_global_colors() -> void:
	var colors: Dictionary = _config.get("colors", {})
	for color_name in colors:
		if color_name.begins_with("_"):
			continue
		var val = colors[color_name]
		if val is Array and val.size() >= 4:
			_theme.set_color(color_name, "Global", _arr_to_color(val))

func _apply_global_theme() -> void:
	get_tree().root.theme = _theme

func get_background(bg_name: String) -> Dictionary:
	var bg = _config.get("backgrounds", {}).get(bg_name, {})
	if bg.is_empty():
		return {"texture": "", "color": [0.05, 0.05, 0.08, 1.0]}
	return bg

func get_color(color_name: String) -> Color:
	var colors: Dictionary = _config.get("colors", {})
	var val = colors.get(color_name, [1.0, 1.0, 1.0, 1.0])
	return _arr_to_color(val)

func get_font_size(size_name: String) -> int:
	var sizes: Dictionary = _config.get("fonts", {}).get("sizes", {})
	return int(sizes.get(size_name, 20))

func apply_background_to(node: Control, bg_name: String) -> void:
	var bg = get_background(bg_name)
	var tex_path = bg.get("texture", "")
	if tex_path != "" and ResourceLoader.exists(tex_path):
		if node is TextureRect:
			node.texture = load(tex_path)
		elif node is ColorRect:
			var tex_rect := TextureRect.new()
			tex_rect.texture = load(tex_path)
			tex_rect.stretch_mode = TextureRect.STRETCH_SCALE
			tex_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
			tex_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
			node.add_child(tex_rect)
			node.color = Color(1, 1, 1, 0)
	else:
		if node is ColorRect:
			node.color = _arr_to_color(bg.get("color", [0.05, 0.05, 0.08, 1.0]))

func get_theme() -> Theme:
	return _theme

func _arr_to_color(arr) -> Color:
	if arr is Array and arr.size() >= 4:
		return Color(arr[0], arr[1], arr[2], arr[3])
	return Color(1, 1, 1, 1)

func reload() -> void:
	_config.clear()
	_theme = Theme.new()
	_load_config()
	_build_theme()
	_apply_global_theme()
	EventBus.settings_changed.emit()
