# Copyright (c) 2025 wippsanrinthailand80-commits. All Rights Reserved.
# Unauthorized copying, modification, distribution, or reproduction is strictly prohibited.
extends Node

signal dialogue_started
signal dialogue_ended
signal line_displayed(speaker_id: String, speaker_name: String, text: String, emotion: String)
signal choices_presented(choices: Array)
signal choice_made(choice_id: String, choice_index: int)

signal affection_changed(character_id: String, axis: String, old_value: float, new_value: float)
signal route_locked(character_id: String)
signal route_completed(character_id: String, ending_id: String)

signal game_saved(slot: int)
signal game_loaded(slot: int)
signal settings_changed

signal scene_transition_started(scene_path: String)
signal scene_transition_finished(scene_path: String)

signal bgm_changed(track_name: String)
signal sfx_played(track_name: String)
signal voice_played(character_id: String, line_id: String)

signal cg_unlocked(cg_id: String)
signal ending_unlocked(ending_id: String)

signal backlog_updated
signal auto_mode_toggled(enabled: bool)
signal skip_mode_toggled(enabled: bool)

signal minigame_started(minigame_id: String)
signal minigame_ended(minigame_id: String, result: Dictionary)

signal time_advanced(new_day: int, new_time: String)
signal day_started(day: int)
signal time_started(day: int, time: String)
