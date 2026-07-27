# Copyright (c) 2025 wippsanrinthailand80-commits. All Rights Reserved.
# Unauthorized copying, modification, distribution, or reproduction is strictly prohibited.
extends Control

@onready var bgm_slider: HSlider = $Panel/Margin/VBox/BGMSection/BGMSlider
@onready var sfx_slider: HSlider = $Panel/Margin/VBox/SFXSection/SFXSlider
@onready var voice_slider: HSlider = $Panel/Margin/VBox/VoiceSection/VoiceSlider
@onready var master_slider: HSlider = $Panel/Margin/VBox/MasterSection/MasterSlider
@onready var text_speed_slider: HSlider = $Panel/Margin/VBox/TextSpeedSection/TextSpeedSlider
@onready var auto_speed_slider: HSlider = $Panel/Margin/VBox/AutoSpeedSection/AutoSpeedSlider
@onready var fullscreen_check: CheckBox = $Panel/Margin/VBox/FullscreenSection/FullscreenCheck
@onready var vsync_check: CheckBox = $Panel/Margin/VBox/VSyncSection/VSyncCheck
@onready var back_button: Button = $Panel/Margin/VBox/BackButton

@onready var bgm_value: Label = $Panel/Margin/VBox/BGMSection/BGMValue
@onready var sfx_value: Label = $Panel/Margin/VBox/SFXSection/SFXValue
@onready var voice_value: Label = $Panel/Margin/VBox/VoiceSection/VoiceValue
@onready var master_value: Label = $Panel/Margin/VBox/MasterSection/MasterValue
@onready var text_speed_value: Label = $Panel/Margin/VBox/TextSpeedSection/TextSpeedValue
@onready var auto_speed_value: Label = $Panel/Margin/VBox/AutoSpeedSection/AutoSpeedValue

var settings: Dictionary = {}

func _ready() -> void:
	settings = SaveManager.load_settings()
	_load_settings_to_ui()
	_connect_signals()
	back_button.pressed.connect(_on_back)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_back()
		get_viewport().set_input_as_handled()

func _connect_signals() -> void:
	bgm_slider.value_changed.connect(_on_bgm_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)
	voice_slider.value_changed.connect(_on_voice_changed)
	master_slider.value_changed.connect(_on_master_changed)
	text_speed_slider.value_changed.connect(_on_text_speed_changed)
	auto_speed_slider.value_changed.connect(_on_auto_speed_changed)
	fullscreen_check.toggled.connect(_on_fullscreen_toggled)
	vsync_check.toggled.connect(_on_vsync_toggled)

func _load_settings_to_ui() -> void:
	bgm_slider.value = settings.get("bgm_volume", 80)
	sfx_slider.value = settings.get("sfx_volume", 80)
	voice_slider.value = settings.get("voice_volume", 90)
	master_slider.value = settings.get("master_volume", 100)
	text_speed_slider.value = settings.get("text_speed", 50)
	auto_speed_slider.value = settings.get("auto_speed", 3.0)
	fullscreen_check.button_pressed = settings.get("fullscreen", true)
	vsync_check.button_pressed = settings.get("vsync", true)

	_update_value_labels()

func _update_value_labels() -> void:
	bgm_value.text = "%d%%" % int(bgm_slider.value)
	sfx_value.text = "%d%%" % int(sfx_slider.value)
	voice_value.text = "%d%%" % int(voice_slider.value)
	master_value.text = "%d%%" % int(master_slider.value)
	text_speed_value.text = "%d%%" % int(text_speed_slider.value)
	auto_speed_value.text = "%.1fs" % auto_speed_slider.value

func _save_settings() -> void:
	SaveManager.save_settings(settings)

func _on_bgm_changed(value: float) -> void:
	settings["bgm_volume"] = int(value)
	_update_value_labels()
	_save_settings()

func _on_sfx_changed(value: float) -> void:
	settings["sfx_volume"] = int(value)
	_update_value_labels()
	_save_settings()

func _on_voice_changed(value: float) -> void:
	settings["voice_volume"] = int(value)
	_update_value_labels()
	_save_settings()

func _on_master_changed(value: float) -> void:
	settings["master_volume"] = int(value)
	_update_value_labels()
	_save_settings()

func _on_text_speed_changed(value: float) -> void:
	settings["text_speed"] = int(value)
	_update_value_labels()
	_save_settings()

func _on_auto_speed_changed(value: float) -> void:
	settings["auto_speed"] = value
	_update_value_labels()
	_save_settings()

func _on_fullscreen_toggled(pressed: bool) -> void:
	settings["fullscreen"] = pressed
	if pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	_save_settings()

func _on_vsync_toggled(pressed: bool) -> void:
	settings["vsync"] = pressed
	if pressed:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	_save_settings()

func _on_back() -> void:
	SceneManager.pop_scene()
