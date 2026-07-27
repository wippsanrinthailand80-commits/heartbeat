extends Node

const SAVE_DIR := "user://saves/"
const SETTINGS_PATH := "user://settings.cfg"
const META_SAVE_PATH := "user://meta_progress.tres"
const MAX_SAVE_SLOTS := 10
const SAVE_VERSION := 1

func _ready() -> void:
	_ensure_save_dir()

func _ensure_save_dir() -> void:
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		DirAccess.make_dir_recursive_absolute(SAVE_DIR)

func save_game(slot: int, save_data: Dictionary) -> bool:
	if slot < 0 or slot >= MAX_SAVE_SLOTS:
		push_error("SaveManager: Invalid slot %d" % slot)
		return false

	var full_data := {
		"version": SAVE_VERSION,
		"timestamp": int(Time.get_unix_time_from_system()),
		"play_time": 0.0,
		"game_state": GameState.get_save_data(),
		"affection": AffectionManager.get_save_data(),
		"screenshot_path": "",
	}

	var path := SAVE_DIR + "save_%d.json" % slot
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("SaveManager: Failed to open save file: %s" % path)
		return false

	file.store_string(JSON.stringify(full_data, "\t"))
	file.close()

	EventBus.game_saved.emit(slot)
	return true

func load_game(slot: int) -> Dictionary:
	var path := SAVE_DIR + "save_%d.json" % slot
	if not FileAccess.file_exists(path):
		return {}

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}

	var json_text := file.get_as_text()
	file.close()

	var json := JSON.new()
	var error := json.parse(json_text)
	if error != OK:
		push_error("SaveManager: Failed to parse save file: %s" % path)
		return {}

	var data: Dictionary = json.data
	var version: int = data.get("version", 0)
	if version < SAVE_VERSION:
		data = _migrate_save(data, version)

	return data

func apply_save_data(slot: int) -> bool:
	var data := load_game(slot)
	if data.is_empty():
		return false

	GameState.load_save_data(data.get("game_state", {}))
	AffectionManager.load_save_data(data.get("affection", {}))

	EventBus.game_loaded.emit(slot)
	return true

func delete_save(slot: int) -> void:
	var path := SAVE_DIR + "save_%d.json" % slot
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)

func get_save_info(slot: int) -> Dictionary:
	var data := load_game(slot)
	if data.is_empty():
		return {"exists": false, "slot": slot}

	return {
		"exists": true,
		"slot": slot,
		"timestamp": data.get("timestamp", 0),
		"chapter": data.get("game_state", {}).get("current_chapter", "???"),
		"day": data.get("game_state", {}).get("current_day", 0),
		"time": data.get("game_state", {}).get("current_time_of_day", "???"),
		"play_time": data.get("play_time", 0.0),
	}

func get_all_save_info() -> Array[Dictionary]:
	var saves: Array[Dictionary] = []
	for i in range(MAX_SAVE_SLOTS):
		saves.append(get_save_info(i))
	return saves

func has_any_saves() -> bool:
	for i in range(MAX_SAVE_SLOTS):
		if FileAccess.file_exists(SAVE_DIR + "save_%d.json" % i):
			return true
	return false

func save_settings(settings: Dictionary) -> void:
	var config := ConfigFile.new()
	for key in settings:
		config.set_value("settings", key, settings[key])
	config.save(SETTINGS_PATH)
	EventBus.settings_changed.emit()

func load_settings() -> Dictionary:
	var config := ConfigFile.new()
	var error := config.load(SETTINGS_PATH)
	if error != OK:
		return _default_settings()

	var settings := {}
	for key in config.get_section_keys("settings"):
		settings[key] = config.get_value("settings", key)
	return settings

func _default_settings() -> Dictionary:
	return {
		"bgm_volume": 80,
		"sfx_volume": 80,
		"voice_volume": 90,
		"master_volume": 100,
		"text_speed": 50,
		"auto_speed": 3.0,
		"fullscreen": true,
		"vsync": true,
		"language": "en",
	}

func save_meta_progress() -> void:
	var meta := {
		"unlocked_routes": GameState.unlocked_routes.duplicate(),
		"unlocked_endings": GameState.unlocked_endings.duplicate(),
		"unlocked_cgs": GameState.unlocked_cgs.duplicate(),
		"total_play_time": 0.0,
		"total_saves_made": 0,
	}
	var file := FileAccess.open(META_SAVE_PATH.replace(".tres", ".json"), FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(meta, "\t"))
		file.close()

func load_meta_progress() -> Dictionary:
	var path := META_SAVE_PATH.replace(".tres", ".json")
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		return {}
	var text := file.get_as_text()
	file.close()
	var json := JSON.new()
	if json.parse(text) != OK:
		return {}
	return json.data

func quick_save() -> bool:
	return save_game(0, {})

func quick_load() -> bool:
	return apply_save_data(0)

func _migrate_save(data: Dictionary, from_version: int) -> Dictionary:
	var migrated := data.duplicate(true)

	if from_version < 1:
		migrated["play_time"] = 0.0
		migrated["version"] = SAVE_VERSION

	return migrated
