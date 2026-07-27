extends Control

@onready var loading_label: Label = $LoadingLabel

func _ready() -> void:
	loading_label.visible = true
	await get_tree().process_frame
	_load_game()

func _load_game() -> void:
	var settings := SaveManager.load_settings()
	if settings.get("fullscreen", true):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

	_register_character_data()
	_register_minigames()
	_load_gallery_data()

	await get_tree().create_timer(0.5).timeout
	loading_label.visible = false
	SceneManager.change_scene("res://source/ui/main_menu/main_menu.tscn", "fade")

func _register_character_data() -> void:
	var chars_dir := "res://data/characters/"
	var dir := DirAccess.open(chars_dir)
	if dir == null:
		return

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if file_name.ends_with(".json"):
			var profile := CharacterProfile.load_from_file(chars_dir + file_name)
			if profile:
				AffectionManager.register_character(profile.id, profile.display_name)
		file_name = dir.get_next()
	dir.list_dir_end()

func _register_minigames() -> void:
	MinigameManager.register_minigame("quiz", "res://source/features/minigames/quiz.tscn", "Quiz Game")
	MinigameManager.register_minigame("fishing", "res://source/features/minigames/fishing.tscn", "Fishing")

func _load_gallery_data() -> void:
	var gallery_path := "res://data/gallery.json"
	if ResourceLoader.exists(gallery_path):
		GalleryManager.load_cg_registry(gallery_path)
