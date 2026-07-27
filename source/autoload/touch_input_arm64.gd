# Copyright (c) 2025 wippsanrinthailand80-commits. All Rights Reserved.
# Unauthorized copying, modification, distribution, or reproduction is strictly prohibited.
extends Node

var _touch_positions: Dictionary = {}
var _touch_start_times: Dictionary = {}
var _swipe_threshold: float = 50.0
var _long_press_time: float = 0.5
var _long_press_timer: Timer
var _long_press_pos: Vector2 = Vector2.ZERO
var _is_long_press_pending: bool = false
var _pinch_start_distance: float = 0.0
var _is_pinching: bool = false

signal touch_started(position: Vector2)
signal touch_ended(position: Vector2)
signal touch_moved(position: Vector2)
signal swipe_detected(direction: Vector2, velocity: float)
signal pinch_detected(scale: float)
signal long_press_detected(position: Vector2)

func _ready() -> void:
	_long_press_timer = Timer.new()
	_long_press_timer.one_shot = true
	add_child(_long_press_timer)
	_long_press_timer.timeout.connect(_on_long_press_timer_timeout)

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_handle_screen_touch(event)
	elif event is InputEventScreenDrag:
		_handle_screen_drag(event)

func _handle_screen_touch(event: InputEventScreenTouch) -> void:
	var idx: int = event.index
	var pos: Vector2 = event.position

	if event.pressed:
		_touch_positions[idx] = pos
		_touch_start_times[idx] = Time.get_ticks_msec()
		touch_started.emit(pos)

		if _touch_positions.size() == 1:
			_long_press_pos = pos
			_is_long_press_pending = true
			_long_press_timer.start(_long_press_time)
	else:
		_touch_positions.erase(idx)
		_touch_start_times.erase(idx)
		touch_ended.emit(pos)

		if _is_long_press_pending:
			_long_press_timer.stop()
			_is_long_press_pending = false

		if _touch_positions.size() == 0:
			_detect_swipe(pos)
			_is_pinching = false
		elif _touch_positions.size() == 1:
			_is_pinching = false

func _handle_screen_drag(event: InputEventScreenDrag) -> void:
	var idx: int = event.index
	var pos: Vector2 = event.position

	_touch_positions[idx] = pos
	touch_moved.emit(pos)

	if _is_long_press_pending:
		var dist: float = pos.distance_to(_long_press_pos)
		if dist > 10.0:
			_long_press_timer.stop()
			_is_long_press_pending = false

	if _touch_positions.size() == 2:
		var keys: Array = _touch_positions.keys()
		var pos_a: Vector2 = _touch_positions[keys[0]]
		var pos_b: Vector2 = _touch_positions[keys[1]]
		var current_distance: float = pos_a.distance_to(pos_b)

		if not _is_pinching:
			_pinch_start_distance = current_distance
			_is_pinching = true
		else:
			if _pinch_start_distance > 0:
				var scale_factor: float = current_distance / _pinch_start_distance
				pinch_detected.emit(scale_factor)

func _on_long_press_timer_timeout() -> void:
	if _is_long_press_pending:
		_is_long_press_pending = false
		long_press_detected.emit(_long_press_pos)

func _detect_swipe(end_pos: Vector2) -> void:
	if _touch_positions.size() > 0:
		return

	var keys: Array = _touch_start_times.keys()
	if keys.is_empty():
		return

	var start_pos: Vector2 = _touch_positions.get(keys[0], Vector2.ZERO)
	var elapsed: float = (Time.get_ticks_msec() - _touch_start_times.get(keys[0], 0)) / 1000.0

	if elapsed > 1.0:
		return

	var distance: float = start_pos.distance_to(end_pos)
	if distance < _swipe_threshold:
		return

	var direction: Vector2 = (end_pos - start_pos).normalized()
	var velocity: float = distance / max(elapsed, 0.01)
	swipe_detected.emit(direction, velocity)

func is_touching() -> bool:
	return _touch_positions.size() > 0

func get_touch_count() -> int:
	return _touch_positions.size()

func get_primary_touch_position() -> Vector2:
	if _touch_positions.is_empty():
		return Vector2.ZERO
	return _touch_positions.values()[0]
