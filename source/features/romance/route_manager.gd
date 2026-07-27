extends Node

var current_route: String = ""
var route_history: Array[String] = []

signal route_started(character_id: String)
signal route_ended(character_id: String, ending_id: String)

func _ready() -> void:
	EventBus.route_locked.connect(_on_route_locked)

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
	return (character_id + "_best_ending") in GameState.unlocked_endings \
		or (character_id + "_good_ending") in GameState.unlocked_endings \
		or (character_id + "_normal_ending") in GameState.unlocked_endings \
		or (character_id + "_bad_ending") in GameState.unlocked_endings

func get_completed_routes() -> Array[String]:
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

	if affection >= 90.0 and trust >= 80.0 and respect >= 70.0:
		return character_id + "_best_ending"
	elif affection >= 75.0 and trust >= 60.0:
		return character_id + "_good_ending"
	elif affection >= 50.0:
		return character_id + "_normal_ending"
	else:
		return character_id + "_bad_ending"

func complete_route(character_id: String, ending_id: String = "") -> void:
	if ending_id.is_empty():
		ending_id = determine_ending(character_id)

	GameState.unlock_ending(ending_id)
	GameState.set_flag(character_id + "_ending", ending_id)

	route_ended.emit(character_id, ending_id)
	current_route = ""

func get_all_route_endings(character_id: String) -> Array[String]:
	var endings: Array[String] = []
	var possible := [
		character_id + "_best_ending",
		character_id + "_good_ending",
		character_id + "_normal_ending",
		character_id + "_bad_ending",
	]
	for ending in possible:
		if ending in GameState.unlocked_endings:
			endings.append(ending)
	return endings

func get_available_routes() -> Array[String]:
	var available: Array[String] = ["common"]
	for route in GameState.unlocked_routes:
		available.append(route)
	return available

func reset_route() -> void:
	current_route = ""

func _on_route_locked(character_id: String) -> void:
	if current_route.is_empty():
		lock_route(character_id)
