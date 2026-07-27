extends Node

var _typed_buffer: String = ""
var _buffer_timeout: float = 2.0
var _last_type_time: float = 0.0

var cheats: Dictionary = {
	"love": _cheat_max_all_affection,
	"rich": _cheat_max_inventory,
	"skip": _cheat_advance_day,
	"unlock": _cheat_unlock_all,
	"godmode": _cheat_godmode,
	"reset": _cheat_reset,
	"chapter2": _cheat_skip_to_chapter2,
}

func _input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return
	if not event.pressed:
		return
	if event.echo:
		return

	var focused := get_viewport().gui_get_focus_owner()
	if focused is LineEdit or focused is TextEdit:
		return

	var char_code: String = event.as_text_physical_keycode().to_lower()
	if char_code.length() != 1:
		return

	var now := Time.get_ticks_msec() / 1000.0
	if now - _last_type_time > _buffer_timeout:
		_typed_buffer = ""
	_last_type_time = now

	_typed_buffer += char_code

	for cheat_code in cheats:
		if _typed_buffer.ends_with(cheat_code):
			_typed_buffer = ""
			cheats[cheat_code].call()
			return

func _cheat_max_all_affection() -> void:
	for char_id in AffectionManager.characters:
		AffectionManager.modify_affection(char_id, "trust", 999.0)
		AffectionManager.modify_affection(char_id, "comfort", 999.0)
		AffectionManager.modify_affection(char_id, "attraction", 999.0)
		AffectionManager.modify_affection(char_id, "respect", 999.0)
	EventBus.settings_changed.emit()

func _cheat_max_inventory() -> void:
	GameState.add_item("golden_ticket", "Golden Ticket", "A shiny golden ticket")
	GameState.add_item("love_letter", "Love Letter", "A heartfelt letter")
	GameState.add_item("chocolate", "Chocolate", "Premium chocolate box")
	GameState.add_item("photo", "Photo", "A developed photograph")
	GameState.add_item("music_box", "Music Box", "A small music box")
	EventBus.settings_changed.emit()

func _cheat_advance_day() -> void:
	GameState.advance_time()
	GameState.advance_time()
	GameState.advance_time()

func _cheat_unlock_all() -> void:
	for char_id in ["alice", "bob", "diana", "edward"]:
		GameState.unlock_route(char_id)
		GameState.unlock_cg("chapter1_%s" % char_id)
	GameState.unlock_cg("chapter1_end")

func _cheat_godmode() -> void:
	_cheat_max_all_affection()
	_cheat_max_inventory()
	_cheat_unlock_all()

func _cheat_reset() -> void:
	GameState.reset_state()
	AffectionManager.characters.clear()

func _cheat_skip_to_chapter2() -> void:
	GameState.current_chapter = "chapter_02"
	GameState.current_day = 8
	GameState.current_time_of_day = "morning"
	GameState.set_flag("intro_completed", true)
	GameState.set_flag("chapter1_completed", true)
