extends Node

var cg_registry: Dictionary = {}

func _ready() -> void:
	pass

func is_cg_unlocked(cg_id: String) -> bool:
	return cg_id in GameState.unlocked_cgs

func unlock_cg(cg_id: String) -> void:
	GameState.unlock_cg(cg_id)

func get_all_cgs() -> Array:
	return cg_registry.values()

func get_unlocked_cgs() -> Array:
	return GameState.unlocked_cgs.duplicate()

func get_cg_count() -> Dictionary:
	return {
		"unlocked": GameState.unlocked_cgs.size(),
		"total": cg_registry.size(),
	}

func register_cg(cg_id: String, path: String, title: String = "", description: String = "") -> void:
	cg_registry[cg_id] = {
		"id": cg_id,
		"path": path,
		"title": title,
		"description": description,
	}

func load_cg_registry(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return

	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK:
		return

	var data: Dictionary = json.data
	for cg_id in data:
		var cg_info: Dictionary = data[cg_id]
		register_cg(cg_id, cg_info.get("path", ""), cg_info.get("title", ""), cg_info.get("description", ""))

func get_cg_info(cg_id: String) -> Dictionary:
	return cg_registry.get(cg_id, {})

func get_ending_cg(character_id: String) -> Array:
	var results: Array = []
	for cg_id in cg_registry:
		if cg_id.begins_with(character_id):
			results.append(cg_registry[cg_id])
	return results
