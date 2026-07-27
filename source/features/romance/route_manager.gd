extends Node

var current_route: String = ""
var route_history: Array = []
var endings_config: Dictionary = {}

const ENDINGS_PATH := "res://data/endings.json"

signal route_started(character_id: String)
signal route_ended(character_id: String, ending_id: String)

func _ready() -> void:
	EventBus.route_locked.connect(_on_route_locked)
	_load_endings_config()

func _load_endings_config() -> void:
	var file := FileAccess.open(ENDINGS_PATH, FileAccess.READ)
	if file == null:
		push_warning("RouteManager: No endings config found")
		return
	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK:
		push_warning("RouteManager: Failed to parse endings config")
		return
	endings_config = json.data

func get_total_endings() -> int:
	return endings_config.get("total_endings", 0)

func get_ending_type_count(type: String) -> int:
	return endings_config.get(type + "_endings", 0)

func get_character_ending_count(character_id: String, ending_type: String = "") -> int:
	var chars: Dictionary = endings_config.get("characters", {})
	if not chars.has(character_id):
		return 0
	var endings: Dictionary = chars[character_id].get("endings", {})
	if ending_type.is_empty():
		return endings.values().reduce(func(a, b): return a + b, 0)
	return endings.get(ending_type, 0)

func lock_route(character_id: String) -> void:
	if current_route == character_id:
		return
	current_route = character_id
	GameState.set_flag("on_route", character_id)
	GameState.set_flag("common_route_completed", true)
	GameState.unlock_route(character_id)
	route_history.append(character_id)
	route_started.emit(character_id)
	EventBus.route_locked.emit(character_id)

func unlock_route(character_id: String) -> void:
	GameState.unlock_route(character_id)

func is_on_route() -> bool:
	return not current_route.is_empty()

func get_current_route() -> String:
	return current_route

func is_route_started(character_id: String) -> bool:
	return character_id in route_history

func is_route_completed(character_id: String) -> bool:
	var char_endings: Dictionary = endings_config.get("ending_ids", {}).get(character_id, {})
	for type in char_endings:
		for ending_id in char_endings[type]:
			if ending_id in GameState.unlocked_endings:
				return true
	return false

func get_completed_routes() -> Array:
	return GameState.unlocked_routes.duplicate()

func get_route_progress(character_id: String) -> float:
	var affection := AffectionManager.get_affection(character_id)
	var trust := AffectionManager.get_axis(character_id, "trust")
	var comfort := AffectionManager.get_axis(character_id, "comfort")
	var attraction := AffectionManager.get_axis(character_id, "attraction")
	var respect := AffectionManager.get_axis(character_id, "respect")

	return (affection + trust + comfort + attraction + respect) / 5.0

func determine_ending(character_id: String) -> String:
	var affection := AffectionManager.get_affection(character_id)
	var trust := AffectionManager.get_axis(character_id, "trust")
	var respect := AffectionManager.get_axis(character_id, "respect")
	var attraction := AffectionManager.get_axis(character_id, "attraction")
	var comfort := AffectionManager.get_axis(character_id, "comfort")

	var char_config: Dictionary = endings_config.get("characters", {}).get(character_id, {})
	var ending_ids: Dictionary = endings_config.get("ending_ids", {}).get(character_id, {})

	if affection >= 90.0 and trust >= 80.0 and respect >= 70.0:
		var good_ids: Array = ending_ids.get("good", [])
		if good_ids.size() > 0:
			return good_ids[0]
	elif affection >= 75.0 and trust >= 60.0:
		var good_ids: Array = ending_ids.get("good", [])
		if good_ids.size() > 0:
			return good_ids[0]

	var bad_ids: Array = ending_ids.get("bad", [])
	if bad_ids.size() > 0:
		return bad_ids[randi() % bad_ids.size()]

	return character_id + "_bad_ending"

func check_secret_ending() -> bool:
	var secret_ids: Dictionary = endings_config.get("ending_ids", {}).get("secret", {})
	var secret_ending_ids: Array = secret_ids.get("secret", [])

	for ending_id in secret_ending_ids:
		if GameState.get_flag("secret_route_active", false):
			var all_max := true
			for char_id in AffectionManager.characters:
				if AffectionManager.get_affection(char_id) < 80.0:
					all_max = false
					break
			if all_max:
				return true
	return false

func complete_route(character_id: String, ending_id: String = "") -> void:
	if ending_id.is_empty():
		if check_secret_ending():
			var secret_ids: Dictionary = endings_config.get("ending_ids", {}).get("secret", {})
			var secret_ending_ids: Array = secret_ids.get("secret", [])
			if secret_ending_ids.size() > 0:
				ending_id = secret_ending_ids[0]
			else:
				ending_id = "true_ending"
		else:
			ending_id = determine_ending(character_id)

	GameState.unlock_ending(ending_id)
	GameState.set_flag(character_id + "_ending", ending_id)

	route_ended.emit(character_id, ending_id)
	current_route = ""

func get_all_route_endings(character_id: String) -> Array:
	var endings: Array = []
	var ending_ids: Dictionary = endings_config.get("ending_ids", {}).get(character_id, {})
	for type in ending_ids:
		for ending_id in ending_ids[type]:
			if ending_id in GameState.unlocked_endings:
				endings.append(ending_id)
	return endings

func get_unlocked_ending_count() -> int:
	return GameState.unlocked_endings.size()

func get_ending_progress() -> Dictionary:
	var unlocked := GameState.unlocked_endings.size()
	var total := get_total_endings()
	return {
		"unlocked": unlocked,
		"total": total,
		"percentage": (float(unlocked) / float(total)) * 100.0 if total > 0 else 0.0,
	}

func get_available_routes() -> Array:
	var available: Array = ["common"]
	for route in GameState.unlocked_routes:
		available.append(route)
	return available

func reset_route() -> void:
	current_route = ""

func _on_route_locked(character_id: String) -> void:
	if current_route.is_empty():
		lock_route(character_id)
