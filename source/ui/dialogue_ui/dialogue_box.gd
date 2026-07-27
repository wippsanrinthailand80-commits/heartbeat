extends Control

@onready var dialogue_panel: PanelContainer = $DialoguePanel
@onready var speaker_label: Label = $DialoguePanel/VBox/SpeakerLabel
@onready var dialogue_label: RichTextLabel = $DialoguePanel/VBox/DialogueLabel
@onready var continue_indicator: TextureRect = $DialoguePanel/VBox/ContinueIndicator
@onready var portrait_display: TextureRect = $PortraitDisplay
@onready var name_panel: PanelContainer = $NamePanel
@onready var name_label: Label = $NamePanel/NameLabel
@onready var choice_container: VBoxContainer = $ChoiceContainer
@onready var text_speed_timer: Timer = $TextSpeedTimer

var displayed_text: String = ""
var full_text: String = ""
var is_text_complete: bool = false
var is_typing: bool = false
var current_character_index: int = 0

const BASE_TEXT_SPEED := 0.03

func _ready() -> void:
	visible = false
	EventBus.line_displayed.connect(_on_line_displayed)
	EventBus.choices_presented.connect(_on_choices_presented)
	EventBus.dialogue_ended.connect(_on_dialogue_ended)
	EventBus.dialogue_started.connect(_on_dialogue_started)

	text_speed_timer.wait_time = BASE_TEXT_SPEED
	text_speed_timer.one_shot = true
	text_speed_timer.timeout.connect(_on_text_speed_timer_timeout)

	choice_container.visible = false
	apply_settings()

func apply_settings() -> void:
	var settings := SaveManager.load_settings()
	var text_speed: float = settings.get("text_speed", 50)
	text_speed_timer.wait_time = BASE_TEXT_SPEED * (1.0 - (text_speed / 100.0) * 0.8)

func _on_dialogue_started() -> void:
	visible = true
	choice_container.visible = false

func _on_dialogue_ended() -> void:
	visible = false
	choice_container.visible = false

func _on_line_displayed(speaker: String, text: String, emotion: String) -> void:
	full_text = text
	displayed_text = ""
	current_character_index = 0
	is_text_complete = false
	is_typing = true

	choice_container.visible = false
	continue_indicator.visible = false

	if speaker.is_empty():
		speaker_label.text = ""
		name_panel.visible = false
	else:
		name_panel.visible = true
		speaker_label.text = speaker

	dialogue_label.text = ""
	text_speed_timer.start()

func _on_text_speed_timer_timeout() -> void:
	if current_character_index < full_text.length():
		displayed_text += full_text[current_character_index]
		current_character_index += 1
		dialogue_label.text = displayed_text
		text_speed_timer.start()
	else:
		is_text_complete = true
		is_typing = false
		continue_indicator.visible = true
		if Input.is_action_pressed("dialogue_skip"):
			EventBus.skip_mode_toggled.emit(true)

func _input(event: InputEvent) -> void:
	if not visible:
		return

	if event.is_action_pressed("dialogue_advance"):
		if is_typing:
			_complete_text_immediately()
		elif is_text_complete:
			DialogueManager.advance()
		get_viewport().set_input_as_handled()

	if event.is_action_pressed("dialogue_auto"):
		DialogueManager.toggle_auto_mode()

	if event.is_action_pressed("dialogue_skip"):
		DialogueManager.toggle_skip_mode()

	if event.is_action_pressed("dialogue_backlog"):
		_toggle_backlog()

func _complete_text_immediately() -> void:
	text_speed_timer.stop()
	displayed_text = full_text
	current_character_index = full_text.length()
	dialogue_label.text = displayed_text
	is_text_complete = true
	is_typing = false
	continue_indicator.visible = true

func _on_choices_presented(choices: Array[Dictionary]) -> void:
	choice_container.visible = true

	for child in choice_container.get_children():
		child.queue_free()

	for i in range(choices.size()):
		var choice: Dictionary = choices[i]
		var button := Button.new()
		button.text = choice.get("text", "Choice %d" % (i + 1))
		button.custom_minimum_size = Vector2(600, 50)
		button.pressed.connect(_on_choice_button_pressed.bind(i))
		choice_container.add_child(button)

func _on_choice_button_pressed(index: int) -> void:
	DialogueManager.make_choice(index)
	choice_container.visible = false

func update_portrait(speaker_id: String, emotion: String = "neutral") -> void:
	var path := PortraitManager.get_portrait_path(speaker_id, emotion)
	if ResourceLoader.exists(path):
		portrait_display.texture = load(path)
		portrait_display.visible = true
	else:
		portrait_display.visible = false

func set_name_color(color: Color) -> void:
	speaker_label.add_theme_color_override("font_color", color)

func _toggle_backlog() -> void:
	var backlog := get_tree().get_first_node_in_group("backlog_ui")
	if backlog:
		backlog.visible = not backlog.visible
