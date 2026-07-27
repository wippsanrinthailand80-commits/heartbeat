class_name DialogueLine
extends Resource

@export var id: String = ""
@export var speaker_id: String = ""
@export var text: String = ""
@export var emotion: String = "neutral"
@export var next_id: String = ""
@export var choices: Array[Dictionary] = []
@export var conditions: Array[Dictionary] = []
@export var effects: Array[Dictionary] = []
@export var bgm: String = ""
@export var sfx: String = ""
@export var background: String = ""
@export var voice_line: String = ""
@export var auto_advance: bool = false
@export var wait_time: float = 0.0
@export var is_narrator: bool = false

func has_choices() -> bool:
	return choices.size() > 0

func evaluate_conditions() -> bool:
	for condition in conditions:
		var type: String = condition.get("type", "flag")
		var key: String = condition.get("key", "")
		var value: Variant = condition.get("value", 0.0)

		match type:
			"flag":
				if GameState.get_flag(key) != value:
					return false
			"affection_above":
				var char_id: String = condition.get("character", "")
				if AffectionManager.get_affection(char_id) <= value:
					return false
			"affection_below":
				var char_id: String = condition.get("character", "")
				if AffectionManager.get_affection(char_id) >= value:
					return false
			"has_item":
				if not GameState.has_item(key):
					return false
			"day_equals":
				if GameState.current_day != value:
					return false
	return true

func apply_effects() -> void:
	for effect in effects:
		var type: String = effect.get("type", "")
		match type:
			"set_flag":
				GameState.set_flag(effect.get("key", ""), effect.get("value", true))
			"affection":
				AffectionManager.modify_affection(
					effect.get("character", ""),
					effect.get("axis", "trust"),
					effect.get("amount", 0.0)
				)
			"add_item":
				GameState.add_item(
					effect.get("item_id", ""),
					effect.get("item_name", ""),
					effect.get("description", "")
				)
			"remove_item":
				GameState.remove_item(effect.get("item_id", ""))
			"unlock_cg":
				GameState.unlock_cg(effect.get("cg_id", ""))
			"unlock_route":
				GameState.unlock_route(effect.get("character", ""))
				EventBus.route_locked.emit(effect.get("character", ""))
			"advance_time":
				GameState.advance_time()
			"change_scene":
				SceneManager.change_scene(effect.get("scene", ""))
