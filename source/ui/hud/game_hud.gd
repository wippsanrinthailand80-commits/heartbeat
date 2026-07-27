extends Control

@onready var day_label: Label = $TopBar/DayLabel
@onready var time_label: Label = $TopBar/TimeLabel
@onready var affection_indicator: HBoxContainer = $TopBar/AffectionIndicator
@onready var menu_button: Button = $TopBar/MenuButton
@onready var auto_button: Button = $TopBar/AutoButton
@onready var skip_button: Button = $TopBar/SkipButton
@onready var save_button: Button = $TopBar/SaveButton
@onready var load_button: Button = $TopBar/LoadButton
@onready var status_button: Button = $TopBar/StatusButton

func _ready() -> void:
	menu_button.pressed.connect(_on_menu_pressed)
	auto_button.pressed.connect(_on_auto_pressed)
	skip_button.pressed.connect(_on_skip_pressed)
	save_button.pressed.connect(_on_save_pressed)
	load_button.pressed.connect(_on_load_pressed)
	status_button.pressed.connect(_on_status_pressed)

	EventBus.time_advanced.connect(_on_time_advanced)
	EventBus.affection_changed.connect(_on_affection_changed)
	EventBus.auto_mode_toggled.connect(_on_auto_toggled)
	EventBus.skip_mode_toggled.connect(_on_skip_toggled)

	_update_display()

func _update_display() -> void:
	day_label.text = "Day %d" % GameState.current_day
	time_label.text = GameState.current_time_of_day.capitalize()
	_update_affection_display()

func _update_affection_display() -> void:
	for child in affection_indicator.get_children():
		child.queue_free()

	for char_id in AffectionManager.characters:
		var affection: float = AffectionManager.get_affection(char_id)
		var label := Label.new()
		label.text = "%s: %.0f" % [AffectionManager.get_character_display_name(char_id), affection]
		label.add_theme_font_size_override("font_size", 16)

		if affection >= 75.0:
			label.add_theme_color_override("font_color", Color.RED)
		elif affection >= 50.0:
			label.add_theme_color_override("font_color", Color.YELLOW)
		else:
			label.add_theme_color_override("font_color", Color.GRAY)

		affection_indicator.add_child(label)

func _on_time_advanced(_day: int, _time: String) -> void:
	_update_display()

func _on_affection_changed(_char_id: String, _axis: String, _old: float, _new: float) -> void:
	_update_affection_display()

func _on_auto_toggled(enabled: bool) -> void:
	auto_button.modulate = Color.GREEN if enabled else Color.WHITE

func _on_skip_toggled(enabled: bool) -> void:
	skip_button.modulate = Color.GREEN if enabled else Color.WHITE

func _on_menu_pressed() -> void:
	_toggle_pause_menu()

func _on_auto_pressed() -> void:
	DialogueManager.toggle_auto_mode()

func _on_skip_pressed() -> void:
	DialogueManager.toggle_skip_mode()

func _on_save_pressed() -> void:
	SaveManager.quick_save()

func _on_load_pressed() -> void:
	SceneManager.push_scene("res://source/ui/save_load_menu/save_load_menu.tscn")

func _on_status_pressed() -> void:
	var status_screen := get_tree().get_first_node_in_group("status_screen")
	if status_screen:
		status_screen._on_open()

func _toggle_pause_menu() -> void:
	var pause_menu := get_tree().get_first_node_in_group("pause_menu")
	if pause_menu:
		pause_menu.visible = not pause_menu.visible
		get_tree().paused = pause_menu.visible
