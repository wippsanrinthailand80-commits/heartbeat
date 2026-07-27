extends Node

var minigame_registry: Dictionary = {}
var active_minigame: String = ""

func register_minigame(id: String, scene_path: String, display_name: String = "") -> void:
	minigame_registry[id] = {
		"id": id,
		"scene_path": scene_path,
		"display_name": display_name if not display_name.is_empty() else id,
	}

func start_minigame(id: String) -> bool:
	if not minigame_registry.has(id):
		push_warning("MinigameManager: Unknown minigame '%s'" % id)
		return false

	active_minigame = id
	EventBus.minigame_started.emit(id)

	var scene_path: String = minigame_registry[id]["scene_path"]
	get_tree().change_scene_to_file(scene_path)
	return true

func end_minigame(result: Dictionary = {}) -> void:
	var finished_id := active_minigame
	active_minigame = ""
	EventBus.minigame_ended.emit(finished_id, result)
	get_tree().change_scene_to_file("res://source/scenes/main.tscn")

func is_minigame_active() -> bool:
	return not active_minigame.is_empty()

func get_available_minigames() -> Array[Dictionary]:
	var available: Array[Dictionary] = []
	for id in minigame_registry:
		available.append(minigame_registry[id])
	return available
