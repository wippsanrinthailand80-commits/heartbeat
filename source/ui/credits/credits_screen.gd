extends Control

@onready var scroll: ScrollContainer = $Panel/Margin/VBox/ScrollContainer
@onready var content: VBoxContainer = $Panel/Margin/VBox/ScrollContainer/Content
@onready var close_button: Button = $Panel/Margin/VBox/CloseButton
@onready var title_label: Label = $Panel/TitleLabel

const CREDITS_DIR := "res://data/credits/"

func _ready() -> void:
	title_label.add_theme_font_size_override("font_size", 36)
	var margin: MarginContainer = $Panel/Margin
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_top", 50)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	var content_box: VBoxContainer = $Panel/Margin/VBox/ScrollContainer/Content
	content_box.add_theme_constant_override("separation", 4)
	close_button.add_theme_font_size_override("font_size", 20)
	close_button.pressed.connect(_on_close)
	_load_credits()

func _input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		_on_close()
		get_viewport().set_input_as_handled()

func _on_close() -> void:
	visible = false
	SceneManager.pop_scene()

func _load_credits() -> void:
	for child in content.get_children():
		child.queue_free()

	var dir := DirAccess.open(CREDITS_DIR)
	if dir == null:
		var fallback := Label.new()
		fallback.text = "No credits available."
		content.add_child(fallback)
		return

	dir.list_dir_begin()
	var file_name := dir.get_next()
	var files := []

	while file_name != "":
		if file_name.ends_with(".json"):
			files.append(file_name)
		file_name = dir.get_next()
	dir.list_dir_end()

	files.sort()

	for fname in files:
		var path := CREDITS_DIR + fname
		var file := FileAccess.open(path, FileAccess.READ)
		if file == null:
			continue

		var json := JSON.new()
		if json.parse(file.get_as_text()) != OK:
			continue

		var data = json.data
		if not data is Dictionary:
			continue
		var section = data.get("section", "Unknown")
		var entries = data.get("entries", [])

		_add_section_header(str(section))

		for entry in entries:
			if not entry is Dictionary:
				continue
			var role = str(entry.get("role", ""))
			var name_display := ""

			if entry.has("name_encrypted"):
				name_display = _decrypt_name(str(entry.get("name_encrypted", "")), str(entry.get("algorithm", "base64")))
			else:
				name_display = str(entry.get("name", "Unknown"))

			var note = str(entry.get("note", ""))
			_add_credit_entry(role, name_display, note)

		_add_spacer()

	_add_copyright()

func _decrypt_name(encrypted: String, algorithm: String) -> String:
	match algorithm:
		"base64":
			var decoded := Marshalls.base64_to_utf8_string(encrypted)
			if decoded.is_empty():
				return "[encrypted]"
			return decoded
		_:
			return "[encrypted]"

func _add_section_header(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 28)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", Color(0.3, 0.8, 1.0))
	label.custom_minimum_size.y = 40
	content.add_child(label)

func _add_credit_entry(role: String, name_text: String, note: String) -> void:
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 2)

	var role_label := Label.new()
	role_label.text = role
	role_label.add_theme_font_size_override("font_size", 16)
	role_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	role_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	vbox.add_child(role_label)

	var name_label := Label.new()
	name_label.text = name_text
	name_label.add_theme_font_size_override("font_size", 22)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(name_label)

	if not note.is_empty():
		var note_label := Label.new()
		note_label.text = note
		note_label.add_theme_font_size_override("font_size", 14)
		note_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		note_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		vbox.add_child(note_label)

	content.add_child(vbox)

func _add_spacer() -> void:
	var spacer := Control.new()
	spacer.custom_minimum_size.y = 30
	content.add_child(spacer)

func _add_copyright() -> void:
	var spacer := Control.new()
	spacer.custom_minimum_size.y = 20
	content.add_child(spacer)

	var label := Label.new()
	label.text = "Made with Godot Engine"
	label.add_theme_font_size_override("font_size", 14)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4))
	content.add_child(label)

	var year_label := Label.new()
	year_label.text = "2025"
	year_label.add_theme_font_size_override("font_size", 14)
	year_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	year_label.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4))
	content.add_child(year_label)
