# Copyright (c) 2025 wippsanrinthailand80-commits. All Rights Reserved.
# Unauthorized copying, modification, distribution, or reproduction is strictly prohibited.
class_name DialogueTree
extends Resource

@export var id: String = ""
@export var start_line_id: String = ""
@export var lines: Dictionary = {}
@export var metadata: Dictionary = {}

func add_line(line: DialogueLine) -> void:
	lines[line.id] = line

func get_line(line_id: String) -> DialogueLine:
	return lines.get(line_id, null)

func get_next_line(current_id: String) -> DialogueLine:
	var current: DialogueLine = get_line(current_id)
	if current == null:
		return null

	if current.has_choices():
		return null

	var next_id: String = current.next_id
	if next_id.is_empty():
		return null

	return get_line(next_id)

func get_choices(current_id: String) -> Array:
	var current: DialogueLine = get_line(current_id)
	if current == null:
		return []
	return current.choices

func evaluate_choices(current_id: String) -> Array:
	var all_choices: Array = get_choices(current_id)
	var valid_choices: Array = []

	for choice in all_choices:
		var conditions: Array = choice.get("conditions", [])
		var valid := true
		for condition in conditions:
			var type: String = condition.get("type", "flag")
			var key: String = condition.get("key", "")
			var value: Variant = condition.get("value", 0.0)
			match type:
				"flag":
					if GameState.get_flag(key) != value:
						valid = false
				"affection_above":
					var char_id: String = condition.get("character", "")
					if AffectionManager.get_affection(char_id) <= value:
						valid = false
				"affection_below":
					var char_id: String = condition.get("character", "")
					if AffectionManager.get_affection(char_id) >= value:
						valid = false
				"day_equals":
					if GameState.current_day != value:
						valid = false
				"has_item":
					if not GameState.has_item(key):
						valid = false
		if valid:
			valid_choices.append(choice)

	return valid_choices

func get_total_lines() -> int:
	return lines.size()

static func load_from_json(json_path: String) -> DialogueTree:
	var file := FileAccess.open(json_path, FileAccess.READ)
	if file == null:
		push_error("DialogueTree: Failed to open: %s" % json_path)
		return null

	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK:
		push_error("DialogueTree: Failed to parse JSON: %s" % json_path)
		return null

	var data: Dictionary = json.data
	var tree := DialogueTree.new()
	tree.id = data.get("id", json_path.get_file().get_basename())
	tree.start_line_id = data.get("start_line", "")
	tree.metadata = data.get("metadata", {})

	var raw_lines: Array = data.get("lines", [])
	for raw_line in raw_lines:
		var line := DialogueLine.new()
		line.id = raw_line.get("id", "")
		line.speaker_id = raw_line.get("speaker", "")
		line.text = raw_line.get("text", "")
		line.emotion = raw_line.get("emotion", "neutral")
		line.next_id = raw_line.get("next", "")
		line.choices = raw_line.get("choices", [])
		line.conditions = raw_line.get("conditions", [])
		line.effects = raw_line.get("effects", [])
		line.bgm = raw_line.get("bgm", "")
		line.sfx = raw_line.get("sfx", "")
		line.background = raw_line.get("background", "")
		line.voice_line = raw_line.get("voice", "")
		line.auto_advance = raw_line.get("auto_advance", false)
		line.wait_time = raw_line.get("wait_time", 0.0)
		line.is_narrator = raw_line.get("narrator", false)
		tree.add_line(line)

	return tree
