extends Control

@onready var backlog_list: ItemList = $Panel/Margin/VBox/BacklogList
@onready var close_button: Button = $Panel/Margin/VBox/CloseButton

func _ready() -> void:
	visible = false
	add_to_group("backlog_ui")
	EventBus.backlog_updated.connect(_refresh_backlog)
	close_button.pressed.connect(_on_close_pressed)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and visible:
		visible = false
		get_viewport().set_input_as_handled()

func _refresh_backlog() -> void:
	backlog_list.clear()
	var entries: Array = GameState.backlog

	for entry in entries:
		var speaker: String = entry.get("speaker", "")
		var text: String = entry.get("text", "")
		var day: int = entry.get("day", 0)
		var time: String = entry.get("time", "")

		var display_text: String = ""
		if not speaker.is_empty():
			display_text = "[b]%s[/b] (Day %d, %s)\n%s" % [speaker, day, time.capitalize(), text]
		else:
			display_text = "(Day %d, %s)\n%s" % [day, time.capitalize(), text]

		backlog_list.add_item(display_text)

	if backlog_list.item_count > 0:
		var last := backlog_list.item_count - 1
		backlog_list.select(last)
		backlog_list.ensure_item_visible(last)
		backlog_list.deselect(last)

func _on_close_pressed() -> void:
	visible = false
