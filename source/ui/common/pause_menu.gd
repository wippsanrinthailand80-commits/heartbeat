# Copyright (c) 2025 wippsanrinthailand80-commits. All Rights Reserved.
# Unauthorized copying, modification, distribution, or reproduction is strictly prohibited.
extends Control

@onready var resume_button: Button = $Panel/VBox/ResumeButton
@onready var save_button: Button = $Panel/VBox/SaveButton
@onready var load_button: Button = $Panel/VBox/LoadButton
@onready var settings_button: Button = $Panel/VBox/SettingsButton
@onready var title_button: Button = $Panel/VBox/TitleButton
@onready var quit_button: Button = $Panel/VBox/QuitButton

func _ready() -> void:
	add_to_group("pause_menu")
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS

	resume_button.pressed.connect(_on_resume)
	save_button.pressed.connect(_on_save)
	load_button.pressed.connect(_on_load)
	settings_button.pressed.connect(_on_settings)
	title_button.pressed.connect(_on_title)
	quit_button.pressed.connect(_on_quit)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if visible:
			_on_resume()
			get_viewport().set_input_as_handled()

func _on_resume() -> void:
	visible = false
	get_tree().paused = false

func _on_save() -> void:
	visible = false
	get_tree().paused = false
	SceneManager.push_scene("res://source/ui/save_load_menu/save_load_menu.tscn")

func _on_load() -> void:
	visible = false
	get_tree().paused = false
	SceneManager.push_scene("res://source/ui/save_load_menu/save_load_menu.tscn")

func _on_settings() -> void:
	visible = false
	get_tree().paused = false
	SceneManager.push_scene("res://source/ui/settings/settings_menu.tscn")

func _on_title() -> void:
	get_tree().paused = false
	AudioManager.stop_bgm(0.5)
	SceneManager.change_scene("res://source/ui/main_menu/main_menu.tscn")

func _on_quit() -> void:
	get_tree().paused = false
	get_tree().quit()
