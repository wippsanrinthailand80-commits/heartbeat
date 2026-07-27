extends Node

var current_chapter: String = "chapter_01"
var current_scene: String = ""
var current_line_index: int = 0
var flags: Dictionary = {}
var unlocked_routes: Array = []
var unlocked_endings: Array = []
var unlocked_cgs: Array = []
var inventory: Array = []
var backlog: Array = []
var is_new_game: bool = true

var current_day: int = 1
var current_time_of_day: String = "morning"

const STARTING_FLAGS := {
	"intro_completed": false,
	"met_alice": false,
	"met_bob": false,
	"met_diana": false,
	"met_edward": false,
	"on_route": "",
	"common_route_completed": false,
}

func _ready() -> void:
	reset_state()

func reset_state() -> void:
	current_chapter = "chapter_01"
	current_scene = ""
	current_line_index = 0
	flags = STARTING_FLAGS.duplicate()
	unlocked_routes.clear()
	unlocked_endings.clear()
	unlocked_cgs.clear()
	inventory.clear()
	backlog.clear()
	current_day = 1
	current_time_of_day = "morning"
	is_new_game = true

func set_flag(flag_name: String, value: Variant = true) -> void:
	flags[flag_name] = value

func get_flag(flag_name: String, default: Variant = false) -> Variant:
	return flags.get(flag_name, default)

func has_flag(flag_name: String) -> bool:
	return flags.has(flag_name)

func add_to_backlog(speaker: String, text: String, emotion: String) -> void:
	backlog.append({
		"speaker": speaker,
		"text": text,
		"emotion": emotion,
		"chapter": current_chapter,
		"day": current_day,
		"time": current_time_of_day,
	})
	EventBus.backlog_updated.emit()

func unlock_cg(cg_id: String) -> void:
	if cg_id not in unlocked_cgs:
		unlocked_cgs.append(cg_id)
		EventBus.cg_unlocked.emit(cg_id)

func unlock_ending(ending_id: String) -> void:
	if ending_id not in unlocked_endings:
		unlocked_endings.append(ending_id)
		EventBus.ending_unlocked.emit(ending_id)

func unlock_route(character_id: String) -> void:
	if character_id not in unlocked_routes:
		unlocked_routes.append(character_id)

func add_item(item_id: String, item_name: String, description: String = "") -> void:
	for item in inventory:
		if item["id"] == item_id:
			item["count"] = item.get("count", 1) + 1
			return
	inventory.append({
		"id": item_id,
		"name": item_name,
		"description": description,
		"count": 1,
	})

func remove_item(item_id: String) -> bool:
	for i in range(inventory.size()):
		if inventory[i]["id"] == item_id:
			inventory[i]["count"] = inventory[i].get("count", 1) - 1
			if inventory[i]["count"] <= 0:
				inventory.remove_at(i)
			return true
	return false

func has_item(item_id: String) -> bool:
	for item in inventory:
		if item["id"] == item_id:
			return true
	return false

func advance_time() -> void:
	var time_order := ["morning", "afternoon", "evening", "night"]
	var idx := time_order.find(current_time_of_day)
	if idx >= 0 and idx < time_order.size() - 1:
		current_time_of_day = time_order[idx + 1]
	else:
		current_time_of_day = time_order[0]
		current_day += 1
		EventBus.day_started.emit(current_day)
	EventBus.time_advanced.emit(current_day, current_time_of_day)
	EventBus.time_started.emit(current_day, current_time_of_day)

func get_save_data() -> Dictionary:
	return {
		"current_chapter": current_chapter,
		"current_scene": current_scene,
		"current_line_index": current_line_index,
		"flags": flags.duplicate(),
		"unlocked_routes": unlocked_routes.duplicate(),
		"unlocked_endings": unlocked_endings.duplicate(),
		"unlocked_cgs": unlocked_cgs.duplicate(),
		"inventory": inventory.duplicate(true),
		"backlog": backlog.duplicate(true),
		"current_day": current_day,
		"current_time_of_day": current_time_of_day,
	}

func load_save_data(data: Dictionary) -> void:
	current_chapter = data.get("current_chapter", "chapter_01")
	current_scene = data.get("current_scene", "")
	current_line_index = data.get("current_line_index", 0)
	flags = data.get("flags", STARTING_FLAGS.duplicate())
	unlocked_routes = data.get("unlocked_routes", [])
	unlocked_endings = data.get("unlocked_endings", [])
	unlocked_cgs = data.get("unlocked_cgs", [])
	inventory = data.get("inventory", [])
	backlog = data.get("backlog", [])
	current_day = data.get("current_day", 1)
	current_time_of_day = data.get("current_time_of_day", "morning")
	is_new_game = false
