# Copyright (c) 2025 wippsanrinthailand80-commits. All Rights Reserved.
# Unauthorized copying, modification, distribution, or reproduction is strictly prohibited.
extends Node

var bgm_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer
var voice_player: AudioStreamPlayer
var bgm_crossfade_player: AudioStreamPlayer

var current_bgm: String = ""
var current_bgm_path: String = ""
var is_crossfading: bool = false

const BGM_DIR := "res://assets/audio/music/"
const SFX_DIR := "res://assets/audio/sfx/"
const VOICE_DIR := "res://assets/audio/voice/"

func _ready() -> void:
	bgm_player = AudioStreamPlayer.new()
	bgm_player.bus = "BGM"
	add_child(bgm_player)

	bgm_crossfade_player = AudioStreamPlayer.new()
	bgm_crossfade_player.bus = "BGM"
	add_child(bgm_crossfade_player)

	sfx_player = AudioStreamPlayer.new()
	sfx_player.bus = "SFX"
	add_child(sfx_player)

	voice_player = AudioStreamPlayer.new()
	voice_player.bus = "Voice"
	add_child(voice_player)

	_apply_settings()

	EventBus.settings_changed.connect(_apply_settings)

func _apply_settings() -> void:
	var settings := SaveManager.load_settings()
	_set_bus_volume("Master", settings.get("master_volume", 100))
	_set_bus_volume("BGM", settings.get("bgm_volume", 80))
	_set_bus_volume("SFX", settings.get("sfx_volume", 80))
	_set_bus_volume("Voice", settings.get("voice_volume", 90))

func _set_bus_volume(bus_name: String, volume_percent: float) -> void:
	var bus_idx := AudioServer.get_bus_index(bus_name)
	if bus_idx >= 0:
		var db := linear_to_db(volume_percent / 100.0)
		AudioServer.set_bus_volume_db(bus_idx, db)

func play_bgm(track_name: String, fade_time: float = 1.0) -> void:
	if track_name == current_bgm:
		return

	var path := BGM_DIR + track_name + ".ogg"
	if not ResourceLoader.exists(path):
		path = BGM_DIR + track_name + ".wav"
	if not ResourceLoader.exists(path):
		push_warning("AudioManager: BGM not found: %s" % track_name)
		return

	current_bgm = track_name
	current_bgm_path = path

	if bgm_player.playing and fade_time > 0:
		_crossfade_bgm(path, fade_time)
	else:
		bgm_player.stream = load(path)
		bgm_player.play()

		if fade_time > 0:
			bgm_player.volume_db = -40.0
			_tween_volume(bgm_player, 0.0, fade_time)

	EventBus.bgm_changed.emit(track_name)

func stop_bgm(fade_time: float = 1.0) -> void:
	if not bgm_player.playing:
		return

	if fade_time > 0:
		_tween_volume(bgm_player, -40.0, fade_time)
		await get_tree().create_timer(fade_time).timeout

	bgm_player.stop()
	current_bgm = ""
	current_bgm_path = ""

func pause_bgm() -> void:
	bgm_player.stream_paused = true

func resume_bgm() -> void:
	bgm_player.stream_paused = false

func play_sfx(track_name: String) -> void:
	var path := SFX_DIR + track_name + ".ogg"
	if not ResourceLoader.exists(path):
		path = SFX_DIR + track_name + ".wav"
	if not ResourceLoader.exists(path):
		push_warning("AudioManager: SFX not found: %s" % track_name)
		return

	sfx_player.stream = load(path)
	sfx_player.play()
	EventBus.sfx_played.emit(track_name)

func play_voice(character_id: String, line_id: String) -> void:
	var path := VOICE_DIR + character_id + "/" + line_id + ".ogg"
	if not ResourceLoader.exists(path):
		path = VOICE_DIR + character_id + "/" + line_id + ".wav"
	if not ResourceLoader.exists(path):
		return

	voice_player.stream = load(path)
	voice_player.play()
	EventBus.voice_played.emit(character_id, line_id)

func stop_voice() -> void:
	voice_player.stop()

func _crossfade_bgm(new_path: String, fade_time: float) -> void:
	if is_crossfading:
		return
	is_crossfading = true

	bgm_crossfade_player.stream = bgm_player.stream
	bgm_crossfade_player.volume_db = bgm_player.volume_db
	bgm_crossfade_player.play(bgm_player.get_playback_position())

	bgm_player.stream = load(new_path)
	bgm_player.volume_db = -40.0
	bgm_player.play()

	var half_time := fade_time / 2.0
	var tween := create_tween().set_parallel(true)
	tween.tween_property(bgm_crossfade_player, "volume_db", -40.0, half_time)
	tween.tween_property(bgm_player, "volume_db", 0.0, half_time)
	await tween.finished

	bgm_crossfade_player.stop()
	is_crossfading = false

func _tween_volume(player: AudioStreamPlayer, target_db: float, duration: float) -> void:
	var tween := create_tween()
	tween.tween_property(player, "volume_db", target_db, duration)
	await tween.finished
