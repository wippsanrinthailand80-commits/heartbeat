extends Node

var _touch_positions: Dictionary = {}
var _touch_start_times: Dictionary = {}
var _swipe_threshold: float = 50.0
var _long_press_time: float = 0.5
var _long_press_timer: Timer
var _long_press_pos: Vector2 = Vector2.ZERO
var _is_long_press_pending: bool = false
var _mouse_held: bool = false
var _mouse_start_time: int = 0
var _mouse_start_pos: Vector2 = Vector2.ZERO

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
	if event is InputEventMouseButton:
		_handle_mouse_button(event)
	elif event is InputEventMouseMotion:
		_handle_mouse_motion(event)

func _handle_mouse_button(event: InputEventMouseButton) -> void:
	if event.button_index != MOUSE_BUTTON_LEFT:
		return

	var pos: Vector2 = event.position

	if event.pressed:
		_mouse_held = true
		_mouse_start_time = Time.get_ticks_msec()
		_mouse_start_pos = pos
		_touch_positions[0] = pos
		_touch_start_times[0] = _mouse_start_time
		touch_started.emit(pos)

		_long_press_pos = pos
		_is_long_press_pending = true
		_long_press_timer.start(_long_press_time)
	else:
		_mouse_held = false
		_touch_positions.erase(0)
		_touch_start_times.erase(0)
		touch_ended.emit(pos)

		if _is_long_press_pending:
			_long_press_timer.stop()
			_is_long_press_pending = false

		_detect_swipe(pos)

func _handle_mouse_motion(event: InputEventMouseMotion) -> void:
	if not _mouse_held:
		return

	var pos: Vector2 = event.position
	_touch_positions[0] = pos
	touch_moved.emit(pos)

	if _is_long_press_pending:
		var dist: float = pos.distance_to(_long_press_pos)
		if dist > 10.0:
			_long_press_timer.stop()
			_is_long_press_pending = false

func _on_long_press_timer_timeout() -> void:
	if _is_long_press_pending:
		_is_long_press_pending = false
		long_press_detected.emit(_long_press_pos)

func _detect_swipe(end_pos: Vector2) -> void:
	var elapsed: float = (Time.get_ticks_msec() - _mouse_start_time) / 1000.0

	if elapsed > 1.0:
		return

	var distance: float = _mouse_start_pos.distance_to(end_pos)
	if distance < _swipe_threshold:
		return

	var direction: Vector2 = (end_pos - _mouse_start_pos).normalized()
	var velocity: float = distance / max(elapsed, 0.01)
	swipe_detected.emit(direction, velocity)

func is_touching() -> bool:
	return _mouse_held

func get_touch_count() -> int:
	return 1 if _mouse_held else 0

func get_primary_touch_position() -> Vector2:
	if not _mouse_held:
		return Vector2.ZERO
	return _touch_positions.get(0, Vector2.ZERO)
