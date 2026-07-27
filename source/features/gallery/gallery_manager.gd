extends Node

var unlocked_cgs: Dictionary = {}

func _ready() -> void:
	pass

func is_cg_unlocked(cg_id: String) -> bool:
	return cg_id in GameState.unlocked_cgs

func unlock_cg(cg_id: String) -> void:
	GameState.unlock_cg(cg_id)

func get_all_cgs() -> Array[Dictionary]:
	return unlocked_cgs.values()

func get_unlocked_cgs() -> Array[String]:
	return GameState.unlocked_cgs.duplicate()

func get_cg_count() -> Dictionary:
	return {
		"unlocked": GameState.unlocked_cgs.size(),
		"total": unlocked_cgs.size(),
	}

func register_cg(cg_id: String, path: String, title: String = "", description: String = "") -> void:
	unlocked_cgs[cg_id] = {
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
	return unlocked_cgs.get(cg_id, {})

func get_ending_cg(character_id: String) -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	for cg_id in unlocked_cgs:
		if cg_id.begins_with(character_id):
			results.append(unlocked_cgs[cg_id])
	return results
