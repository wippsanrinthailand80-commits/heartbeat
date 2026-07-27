# Copyright (c) 2025 wippsanrinthailand80-commits. All Rights Reserved.
# Unauthorized copying, modification, distribution, or reproduction is strictly prohibited.
extends Node

const MAX_AFFECTION := 100.0
const MIN_AFFECTION := 0.0
const DEFAULT_AFFECTION := 30.0

var characters: Dictionary = {}

func _ready() -> void:
	EventBus.route_locked.connect(_on_route_locked)

func register_character(char_id: String, display_name: String, max_affection: float = MAX_AFFECTION) -> void:
	characters[char_id] = {
		"display_name": display_name,
		"affection": DEFAULT_AFFECTION,
		"max_affection": max_affection,
		"trust": 50.0,
		"comfort": 50.0,
		"attraction": 30.0,
		"respect": 50.0,
		"axis_locked": false,
	}

func get_affection(char_id: String) -> float:
	if not characters.has(char_id):
		return 0.0
	return characters[char_id]["affection"]

func get_axis(char_id: String, axis: String) -> float:
	if not characters.has(char_id):
		return 0.0
	return characters[char_id].get(axis, 0.0)

func modify_affection(char_id: String, axis: String, amount: float) -> void:
	if not characters.has(char_id):
		push_warning("AffectionManager: Unknown character '%s'" % char_id)
		return

	if characters[char_id].get("axis_locked", false):
		return

	var char_data: Dictionary = characters[char_id]
	var old_value: float = char_data.get(axis, 0.0)
	var new_value: float = clampf(old_value + amount, MIN_AFFECTION, char_data["max_affection"])

	char_data[axis] = new_value

	char_data["affection"] = (
		char_data["trust"] * 0.3
		+ char_data["comfort"] * 0.25
		+ char_data["attraction"] * 0.25
		+ char_data["respect"] * 0.2
	)

	char_data["affection"] = clampf(char_data["affection"], MIN_AFFECTION, char_data["max_affection"])

	EventBus.affection_changed.emit(char_id, axis, old_value, new_value)

func get_all_characters() -> Dictionary:
	return characters.duplicate(true)

func get_character_display_name(char_id: String) -> String:
	if not characters.has(char_id):
		return char_id
	return characters[char_id]["display_name"]

func get_highest_affection_character() -> String:
	var highest_id := ""
	var highest_value := -1.0
	for char_id in characters:
		var affection: float = characters[char_id]["affection"]
		if affection > highest_value:
			highest_value = affection
			highest_id = char_id
	return highest_id

func is_romanceable(char_id: String) -> bool:
	return characters.has(char_id) and characters[char_id]["affection"] >= 70.0

func get_relationship_level(char_id: String) -> String:
	var affection := get_affection(char_id)
	if affection >= 90.0:
		return "soulmate"
	elif affection >= 75.0:
		return "love"
	elif affection >= 60.0:
		return "close"
	elif affection >= 45.0:
		return "friend"
	elif affection >= 30.0:
		return "acquaintance"
	else:
		return "stranger"

func _on_route_locked(character_id: String) -> void:
	for char_id in characters:
		characters[char_id]["axis_locked"] = (char_id != character_id)

func get_save_data() -> Dictionary:
	return characters.duplicate(true)

func load_save_data(data: Dictionary) -> void:
	characters = data.duplicate(true)
