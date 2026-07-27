# Copyright (c) 2025 wippsanrinthailand80-commits. All Rights Reserved.
# Unauthorized copying, modification, distribution, or reproduction is strictly prohibited.
extends Node

var portrait_data: Dictionary = {}
var active_portraits: Dictionary = {}

const CHARACTERS_DIR := "res://data/characters/"

func _ready() -> void:
	_load_all_character_data()

func _load_all_character_data() -> void:
	var dir := DirAccess.open(CHARACTERS_DIR)
	if dir == null:
		push_warning("PortraitManager: Cannot open characters dir")
		return

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if file_name.ends_with(".json"):
			var profile := CharacterProfile.load_from_file(CHARACTERS_DIR + file_name)
			if profile:
				portrait_data[profile.id] = profile
				AffectionManager.register_character(profile.id, profile.display_name)
		file_name = dir.get_next()
	dir.list_dir_end()

func get_portrait_path(speaker_id: String, emotion: String = "neutral") -> String:
	if not portrait_data.has(speaker_id):
		push_warning("PortraitManager: Unknown character '%s'" % speaker_id)
		return "res://assets/art/characters/placeholder.png"

	var profile: CharacterProfile = portrait_data[speaker_id]
	return profile.get_portrait_path(emotion)

func get_character_color(speaker_id: String) -> Color:
	if portrait_data.has(speaker_id):
		return portrait_data[speaker_id].color
	return Color.WHITE

func get_character_name(speaker_id: String) -> String:
	if portrait_data.has(speaker_id):
		return portrait_data[speaker_id].display_name
	return speaker_id

func has_character(speaker_id: String) -> bool:
	return portrait_data.has(speaker_id)

func get_profile(speaker_id: String) -> CharacterProfile:
	return portrait_data.get(speaker_id, null)

func get_all_profiles() -> Array[CharacterProfile]:
	var profiles: Array[CharacterProfile] = []
	for key in portrait_data:
		profiles.append(portrait_data[key])
	return profiles

func set_active_portrait(speaker_id: String, emotion: String = "neutral") -> void:
	active_portraits[speaker_id] = emotion

func clear_active_portrait(speaker_id: String) -> void:
	active_portraits.erase(speaker_id)

func clear_all_portraits() -> void:
	active_portraits.clear()

func get_active_portraits() -> Dictionary:
	return active_portraits.duplicate()
