# Copyright (c) 2025 wippsanrinthailand80-commits. All Rights Reserved.
# Unauthorized copying, modification, distribution, or reproduction is strictly prohibited.
extends Control

@onready var title_label: Label = $Panel/TitleLabel
@onready var scroll: ScrollContainer = $Panel/Margin/VBox/ScrollContainer
@onready var content: VBoxContainer = $Panel/Margin/VBox/ScrollContainer/Content
@onready var close_button: Button = $Panel/Margin/VBox/CloseButton

func _ready() -> void:
	close_button.pressed.connect(_on_close)

func _on_open() -> void:
	visible = true
	_populate()

func _on_close() -> void:
	visible = false

func _populate() -> void:
	for child in content.get_children():
		child.queue_free()

	_add_section("Day %d - %s" % [GameState.current_day, GameState.current_time_of_day.capitalize()])
	_add_separator()

	if AffectionManager.characters.size() > 0:
		_add_header("Affection")
		for char_id in AffectionManager.characters:
			var display_name: String = AffectionManager.get_character_display_name(char_id)
			var affection: float = AffectionManager.get_affection(char_id)
			var relationship: String = AffectionManager.get_relationship_level(char_id)
			var trust: float = AffectionManager.get_axis(char_id, "trust")
			var comfort: float = AffectionManager.get_axis(char_id, "comfort")
			var attraction: float = AffectionManager.get_axis(char_id, "attraction")
			var respect: float = AffectionManager.get_axis(char_id, "respect")

			_add_header(display_name)
			_add_row("Relationship", relationship.capitalize())
			_add_row("Affection", "%.0f / 100" % affection)
			_add_progress_bar(affection / 100.0)
			_add_row("Trust", "%.0f" % trust)
			_add_row("Comfort", "%.0f" % comfort)
			_add_row("Attraction", "%.0f" % attraction)
			_add_row("Respect", "%.0f" % respect)
			_add_separator()
	else:
		_add_row("No characters registered yet.")
		_add_separator()

	if GameState.inventory.size() > 0:
		_add_header("Inventory")
		for item in GameState.inventory:
			var count: int = item.get("count", 1)
			var display: String = item.get("name", item.get("id", "???"))
			if count > 1:
				display += " x%d" % count
			_add_row(display, item.get("description", ""))
		_add_separator()
	else:
		_add_header("Inventory")
		_add_row("Empty")
		_add_separator()

	if GameState.flags.size() > 0:
		_add_header("Flags")
		for key in GameState.flags:
			var val: Variant = GameState.flags[key]
			_add_row(key, str(val))
		_add_separator()

	if GameState.unlocked_routes.size() > 0:
		_add_header("Unlocked Routes")
		for route in GameState.unlocked_routes:
			_add_row(route.capitalize())
		_add_separator()

	if GameState.unlocked_cgs.size() > 0:
		_add_header("Unlocked CGs")
		for cg in GameState.unlocked_cgs:
			_add_row(cg)
		_add_separator()

	if GameState.unlocked_endings.size() > 0:
		_add_header("Unlocked Endings")
		for ending in GameState.unlocked_endings:
			_add_row(ending)

	var progress: Dictionary = RouteManager.get_ending_progress()
	if progress.get("total", 0) > 0:
		_add_separator()
		_add_header("Ending Progress")
		_add_row("Unlocked", "%d / %d" % [progress.get("unlocked", 0), progress.get("total", 0)])
		_add_progress_bar(progress.get("percentage", 0.0) / 100.0)

func _add_header(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 24)
	label.add_theme_color_override("font_color", Color(0.3, 0.8, 1.0))
	content.add_child(label)

func _add_row(label_text: String, value_text: String = "") -> void:
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 20)

	var lbl := Label.new()
	lbl.text = label_text
	lbl.add_theme_font_size_override("font_size", 18)
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(lbl)

	if not value_text.is_empty():
		var val := Label.new()
		val.text = value_text
		val.add_theme_font_size_override("font_size", 18)
		val.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		hbox.add_child(val)

	content.add_child(hbox)

func _add_progress_bar(ratio: float) -> void:
	var bar := ProgressBar.new()
	bar.custom_minimum_size = Vector2(0, 16)
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.max_value = 1.0
	bar.value = clampf(ratio, 0.0, 1.0)
	bar.show_percentage = false
	content.add_child(bar)

func _add_separator() -> void:
	var sep := HSeparator.new()
	sep.custom_minimum_size.y = 10
	content.add_child(sep)

func _add_section(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 28)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(label)
