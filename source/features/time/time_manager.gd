extends Node

signal day_started(day: int)
signal time_started(day: int, time: String)

var schedule_data: Dictionary = {}

const TIME_PERIODS := ["morning", "afternoon", "evening", "night"]

func _ready() -> void:
	EventBus.time_advanced.connect(_on_time_advanced)

func register_schedule(day: int, time: String, events: Array) -> void:
	var key := "%d_%s" % [day, time]
	schedule_data[key] = events

func get_events(day: int, time: String) -> Array:
	var key := "%d_%s" % [day, time]
	return schedule_data.get(key, [])

func get_current_events() -> Array:
	return get_events(GameState.current_day, GameState.current_time_of_day)

func is_time_available(target_time: String) -> bool:
	var current_idx := TIME_PERIODS.find(GameState.current_time_of_day)
	var target_idx := TIME_PERIODS.find(target_time)
	return target_idx >= current_idx

func advance_to_time(target_time: String) -> void:
	while GameState.current_time_of_day != target_time:
		GameState.advance_time()

func advance_to_day(target_day: int) -> void:
	while GameState.current_day < target_day:
		GameState.advance_time()

func get_time_index(time: String) -> int:
	return TIME_PERIODS.find(time)

func get_display_time() -> String:
	return "Day %d - %s" % [GameState.current_day, GameState.current_time_of_day.capitalize()]

func load_schedule_from_file(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return

	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK:
		return

	var data: Dictionary = json.data
	for day_key in data:
		if day_key.begins_with("day_"):
			var day_num: int = day_key.substr(4).to_int()
			var times: Dictionary = data[day_key]
			for time_key in times:
				register_schedule(day_num, time_key, times[time_key])

func _on_time_advanced(_new_day: int, _new_time: String) -> void:
	var events := get_current_events()
	for event in events:
		var event_type: String = event.get("type", "")
		match event_type:
			"flag":
				GameState.set_flag(event.get("key", ""), event.get("value", true))
			"affection":
				AffectionManager.modify_affection(
					event.get("character", ""),
					event.get("axis", "trust"),
					event.get("amount", 0.0)
				)
