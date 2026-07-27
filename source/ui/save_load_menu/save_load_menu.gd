extends Control

var is_save_mode: bool = true
var selected_slot: int = -1

@onready var title_label: Label = $Panel/TitleLabel
@onready var slot_container: VBoxContainer = $Panel/Margin/SlotContainer
@onready var save_button: Button = $Panel/Margin/HBox/SaveButton
@onready var load_button: Button = $Panel/Margin/HBox/LoadButton
@onready var delete_button: Button = $Panel/Margin/HBox/DeleteButton
@onready var back_button: Button = $Panel/Margin/HBox/BackButton
@onready var confirm_dialog: ConfirmationDialog = $ConfirmDialog

var slot_buttons: Array[Button] = []

func _ready() -> void:
	_create_save_slots()
	_connect_signals()
	_update_ui()

func _create_save_slots() -> void:
	for i in range(SaveManager.MAX_SAVE_SLOTS):
		var button := Button.new()
		button.custom_minimum_size = Vector2(800, 60)
		button.text = "Slot %d - Empty" % (i + 1)
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.pressed.connect(_on_slot_pressed.bind(i))
		slot_container.add_child(button)
		slot_buttons.append(button)

func _connect_signals() -> void:
	save_button.pressed.connect(_on_save_pressed)
	load_button.pressed.connect(_on_load_pressed)
	delete_button.pressed.connect(_on_delete_pressed)
	back_button.pressed.connect(_on_back_pressed)
	confirm_dialog.confirmed.connect(_on_confirm_delete)

func _update_ui() -> void:
	title_label.text = "Save Game" if is_save_mode else "Load Game"
	save_button.visible = is_save_mode
	load_button.visible = not is_save_mode

	for i in range(SaveManager.MAX_SAVE_SLOTS):
		var info: Dictionary = SaveManager.get_save_info(i)
		var button: Button = slot_buttons[i]

		if info.get("exists", false):
			var timestamp: int = info.get("timestamp", 0)
			var date_str := Time.get_datetime_string_from_unix_time(timestamp) if timestamp > 0 else "Unknown"
			var chapter: String = info.get("chapter", "???")
			var day: int = info.get("day", 0)
			var time: String = info.get("time", "???")
			button.text = "Slot %d - %s (Day %d, %s) [%s]" % [
				i + 1, chapter, day, time.capitalize(), date_str
			]
		else:
			button.text = "Slot %d - Empty" % (i + 1)

		button.modulate = Color(1, 1, 1, 1) if i == selected_slot else Color(0.8, 0.8, 0.8, 1)

func _on_slot_pressed(index: int) -> void:
	selected_slot = index
	_update_ui()

func _on_save_pressed() -> void:
	if selected_slot < 0:
		return

	if SaveManager.get_save_info(selected_slot).get("exists", false):
		confirm_dialog.dialog_text = "Overwrite save in slot %d?" % (selected_slot + 1)
		confirm_dialog.popup_centered()
	else:
		_perform_save()

func _perform_save() -> void:
	if SaveManager.save_game(selected_slot):
		_update_ui()

func _on_load_pressed() -> void:
	if selected_slot < 0:
		return

	if SaveManager.apply_save_data(selected_slot):
		SceneManager.change_scene("res://source/scenes/gameplay.tscn")

func _on_delete_pressed() -> void:
	if selected_slot < 0:
		return
	confirm_dialog.dialog_text = "Delete save in slot %d?" % (selected_slot + 1)
	confirm_dialog.popup_centered()

func _on_confirm_delete() -> void:
	SaveManager.delete_save(selected_slot)
	selected_slot = -1
	_update_ui()

func _on_back_pressed() -> void:
	SceneManager.pop_scene()
