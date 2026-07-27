# Copyright (c) 2025 wippsanrinthailand80-commits. All Rights Reserved.
# Unauthorized copying, modification, distribution, or reproduction is strictly prohibited.
extends Node

var current_tree: DialogueTree = null
var current_line_id: String = ""
var is_dialogue_active: bool = false
var is_waiting_for_input: bool = false
var history: Array = []

var auto_mode: bool = false
var skip_mode: bool = false
var auto_timer: Timer

const DEFAULT_AUTO_DELAY := 3.0

func _ready() -> void:
	auto_timer = Timer.new()
	auto_timer.one_shot = true
	add_child(auto_timer)
	auto_timer.timeout.connect(_on_auto_timer_timeout)

func _get_auto_delay() -> float:
	var settings := SaveManager.load_settings()
	return settings.get("auto_speed", DEFAULT_AUTO_DELAY)

func start_dialogue(tree: DialogueTree) -> void:
	if tree == null:
		push_error("DialogueManager: Null dialogue tree")
		return

	current_tree = tree
	current_line_id = tree.start_line_id
	is_dialogue_active = true
	history.clear()

	EventBus.dialogue_started.emit()
	_display_current_line()

func start_dialogue_from_file(json_path: String) -> void:
	var tree := DialogueTree.load_from_json(json_path)
	if tree:
		start_dialogue(tree)

func start_dialogue_from_id(tree_id: String) -> void:
	var dir := DirAccess.open("res://data/dialogues/")
	if dir == null:
		push_error("DialogueManager: Cannot open dialogues directory")
		return

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if file_name.ends_with(".json"):
			var base_name := file_name.get_basename()
			if base_name == tree_id:
				start_dialogue_from_file("res://data/dialogues/" + file_name)
				return
			for sub in ["chapter_01", "chapter_02", "chapter_03", "chapter_04", "chapter_05"]:
				if dir.dir_exists(sub):
					var sub_path := "res://data/dialogues/%s/%s.json" % [sub, tree_id]
					if ResourceLoader.exists(sub_path):
						start_dialogue_from_file(sub_path)
						return
		file_name = dir.get_next()
	dir.list_dir_end()
	push_error("DialogueManager: Dialogue not found: %s" % tree_id)

func advance() -> void:
	if not is_dialogue_active:
		return

	if is_waiting_for_input:
		is_waiting_for_input = false
		_move_to_next()
		return

	if current_tree == null:
		return

	var line: DialogueLine = current_tree.get_line(current_line_id)
	if line == null:
		end_dialogue()
		return

	if line.has_choices():
		return

	_move_to_next()

func _move_to_next() -> void:
	if current_tree == null:
		return

	var line: DialogueLine = current_tree.get_line(current_line_id)
	if line == null:
		end_dialogue()
		return

	line.apply_effects()

	if not line.next_id.is_empty():
		current_line_id = line.next_id
		_display_current_line()
	else:
		end_dialogue()

func _display_current_line() -> void:
	if current_tree == null:
		return

	var line: DialogueLine = current_tree.get_line(current_line_id)
	if line == null:
		end_dialogue()
		return

	if not line.evaluate_conditions():
		_move_to_next()
		return

	if not line.bgm.is_empty():
		AudioManager.play_bgm(line.bgm)
	if not line.sfx.is_empty():
		AudioManager.play_sfx(line.sfx)
	if not line.background.is_empty():
		EventBus.scene_transition_started.emit(line.background)
	if not line.voice_line.is_empty():
		AudioManager.play_voice(line.speaker_id, line.voice_line)

	var speaker_name: String = ""
	var speaker_id: String = ""
	if not line.is_narrator and not line.speaker_id.is_empty():
		speaker_id = line.speaker_id
		speaker_name = AffectionManager.get_character_display_name(line.speaker_id)

	GameState.add_to_backlog(speaker_name, line.text, line.emotion)

	_save_state_to_history(line)

	EventBus.line_displayed.emit(speaker_id, speaker_name, line.text, line.emotion)

	if line.has_choices():
		var valid_choices: Array = current_tree.evaluate_choices(current_line_id)
		EventBus.choices_presented.emit(valid_choices)
		is_waiting_for_input = false
	elif line.auto_advance or auto_mode:
		if line.wait_time > 0.0:
			await get_tree().create_timer(line.wait_time).timeout
		_move_to_next()
	else:
		is_waiting_for_input = true

func make_choice(choice_index: int) -> void:
	if current_tree == null:
		return

	var valid_choices: Array = current_tree.evaluate_choices(current_line_id)
	if choice_index < 0 or choice_index >= valid_choices.size():
		push_error("DialogueManager: Invalid choice index %d" % choice_index)
		return

	var choice: Dictionary = valid_choices[choice_index]
	var choice_id: String = choice.get("id", "")
	var target_id: String = choice.get("target", "")
	var effects: Array = choice.get("effects", [])

	for effect in effects:
		var type: String = effect.get("type", "")
		match type:
			"set_flag":
				GameState.set_flag(effect.get("key", ""), effect.get("value", true))
			"affection":
				AffectionManager.modify_affection(
					effect.get("character", ""),
					effect.get("axis", "trust"),
					effect.get("amount", 0.0)
				)
			"add_item":
				GameState.add_item(
					effect.get("item_id", ""),
					effect.get("item_name", ""),
					effect.get("description", "")
				)
			"remove_item":
				GameState.remove_item(effect.get("item_id", ""))
			"unlock_cg":
				GameState.unlock_cg(effect.get("cg_id", ""))
			"unlock_route":
				GameState.unlock_route(effect.get("character", ""))
				EventBus.route_locked.emit(effect.get("character", ""))
			"advance_time":
				GameState.advance_time()
			"change_scene":
				SceneManager.change_scene(effect.get("scene", ""))

	EventBus.choice_made.emit(choice_id, choice_index)
	is_waiting_for_input = false

	if not target_id.is_empty():
		current_line_id = target_id
		_display_current_line()
	else:
		_move_to_next()

func end_dialogue() -> void:
	is_dialogue_active = false
	is_waiting_for_input = false
	current_tree = null
	current_line_id = ""
	auto_timer.stop()
	EventBus.dialogue_ended.emit()

func toggle_auto_mode() -> void:
	auto_mode = not auto_mode
	skip_mode = false
	EventBus.auto_mode_toggled.emit(auto_mode)
	if auto_mode and is_waiting_for_input:
		_start_auto_timer()

func toggle_skip_mode() -> void:
	skip_mode = not skip_mode
	auto_mode = false
	auto_timer.stop()
	EventBus.skip_mode_toggled.emit(skip_mode)
	if skip_mode and is_dialogue_active:
		_perform_skip()

func _start_auto_timer() -> void:
	auto_timer.start(_get_auto_delay())

func _on_auto_timer_timeout() -> void:
	if auto_mode and is_dialogue_active and is_waiting_for_input:
		advance()

func _perform_skip() -> void:
	while skip_mode and is_dialogue_active:
		if is_waiting_for_input:
			advance()
		await get_tree().create_timer(0.05).timeout

func _save_state_to_history(line: DialogueLine) -> void:
	history.append({
		"line_id": line.id,
		"speaker_id": line.speaker_id,
		"text": line.text,
		"emotion": line.emotion,
		"day": GameState.current_day,
		"time": GameState.current_time_of_day,
	})

func get_backlog() -> Array:
	return GameState.backlog.duplicate(true)

func rollback() -> void:
	if history.size() < 2:
		return

	history.pop_back()
	var prev_state: Dictionary = history.back()
	current_line_id = prev_state["line_id"]
	_display_current_line()
