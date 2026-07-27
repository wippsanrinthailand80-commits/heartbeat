extends Control

@onready var background: TextureRect = $Background
@onready var dialogue_box: Control = $UILayer/DialogueBox
@onready var game_hud: Control = $UILayer/GameHUD
@onready var pause_menu: Control = $UILayer/PauseMenu
@onready var backlog: Control = $UILayer/Backlog

var current_background_path: String = ""
var character_nodes: Dictionary = {}

func _ready() -> void:
	_connect_signals()
	_load_intro()

func _connect_signals() -> void:
	EventBus.line_displayed.connect(_on_line_displayed)
	EventBus.dialogue_ended.connect(_on_dialogue_ended)
	EventBus.scene_transition_started.connect(_on_scene_change_requested)
	EventBus.cg_unlocked.connect(_on_cg_unlocked)

func _load_intro() -> void:
	var intro_path := "res://data/dialogues/chapter_01/intro.json"
	if ResourceLoader.exists(intro_path):
		DialogueManager.start_dialogue_from_file(intro_path)

func _on_line_displayed(speaker: String, text: String, emotion: String) -> void:
	pass

func _on_dialogue_ended() -> void:
	pass

func _on_scene_change_requested(scene_path: String) -> void:
	if scene_path.begins_with("res://"):
		_load_background(scene_path)

func _load_background(path: String) -> void:
	if current_background_path == path:
		return
	if ResourceLoader.exists(path):
		var tween := create_tween()
		tween.tween_property(background, "modulate:a", 0.0, 0.3)
		await tween.finished
		background.texture = load(path)
		current_background_path = path
		var fade_in := create_tween()
		fade_in.tween_property(background, "modulate:a", 1.0, 0.3)

func _on_cg_unlocked(cg_id: String) -> void:
	pass
