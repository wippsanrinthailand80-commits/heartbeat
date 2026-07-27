extends Control

@onready var background: TextureRect = $Background
@onready var dialogue_box: Control = $UILayer/DialogueBox
@onready var game_hud: Control = $UILayer/GameHUD
@onready var pause_menu: Control = $UILayer/PauseMenu
@onready var backlog: Control = $UILayer/Backlog
@onready var status_screen: Control = $UILayer/StatusScreen

var current_background_path: String = ""
var character_nodes: Dictionary = {}

func _ready() -> void:
	_apply_safe_area()
	_connect_signals()
	status_screen.add_to_group("status_screen")
	EventBus.scene_transition_started.connect(_on_scene_transition_started)
	if GameState.is_new_game:
		_load_intro()
	else:
		_resume_from_save()

func _apply_safe_area() -> void:
	var safe := DisplayServer.get_display_safe_area()
	var viewport_size := get_viewport().get_visible_rect().size
	var margin_left := int(safe.position.x)
	var margin_top := int(safe.position.y)
	var margin_right := int(viewport_size.x - safe.end.x)
	var margin_bottom := int(viewport_size.y - safe.end.y)

	if dialogue_box and dialogue_box.has_node("DialoguePanel"):
		var dp: Control = dialogue_box.get_node("DialoguePanel")
		dp.offset_left = max(margin_left + 40, dp.offset_left)
		dp.offset_right = -max(margin_right + 40, abs(dp.offset_right))

	if game_hud and game_hud.has_node("TopBar"):
		var tb: Control = game_hud.get_node("TopBar")
		tb.offset_left = max(margin_left + 10, 0)
		tb.offset_right = -max(margin_right + 10, 0)
		tb.offset_bottom = max(margin_top + 52, 52)

func _connect_signals() -> void:
	EventBus.line_displayed.connect(_on_line_displayed)
	EventBus.dialogue_ended.connect(_on_dialogue_ended)
	EventBus.cg_unlocked.connect(_on_cg_unlocked)
	EventBus.affection_changed.connect(_on_affection_changed)
	RouteManager.route_ended.connect(_on_route_ended)

func _load_intro() -> void:
	var intro_path := "res://data/dialogues/chapter_01/intro.json"
	if ResourceLoader.exists(intro_path):
		DialogueManager.start_dialogue_from_file(intro_path)

func _resume_from_save() -> void:
	pass

func _on_line_displayed(speaker_id: String, _speaker_name: String, _text: String, emotion: String) -> void:
	if not speaker_id.is_empty():
		dialogue_box.update_portrait(speaker_id, emotion)

func _on_dialogue_ended() -> void:
	pass

func _on_cg_unlocked(cg_id: String) -> void:
	pass

func _on_affection_changed(_char_id: String, _axis: String, _old: float, _new: float) -> void:
	pass

func _on_scene_transition_started(scene_path: String) -> void:
	load_scene_background(scene_path)

func _on_route_ended(character_id: String, ending_id: String) -> void:
	SceneManager.push_scene("res://source/ui/ending/ending_screen.tscn")

func load_scene_background(path: String) -> void:
	if current_background_path == path:
		return
	if not ResourceLoader.exists(path):
		return
	var ext := path.get_extension().to_lower()
	if ext not in ["png", "jpg", "jpeg", "webp", "bmp", "svg"]:
		return

	var tween := create_tween()
	tween.tween_property(background, "modulate:a", 0.0, 0.3)
	await tween.finished
	background.texture = load(path)
	current_background_path = path
	var fade_in := create_tween()
	fade_in.tween_property(background, "modulate:a", 1.0, 0.3)
