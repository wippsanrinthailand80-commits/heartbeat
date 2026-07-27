extends Control

func _ready() -> void:
	var back_button: Button = $BackButton
	back_button.pressed.connect(_on_back_pressed)

func _on_back_pressed() -> void:
	MinigameManager.end_minigame()
