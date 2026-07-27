# Copyright (c) 2025 wippsanrinthailand80-commits. All Rights Reserved.
# Unauthorized copying, modification, distribution, or reproduction is strictly prohibited.
extends Node

signal touch_started(position: Vector2)
signal touch_ended(position: Vector2)
signal touch_moved(position: Vector2)
signal swipe_detected(direction: Vector2, velocity: float)
signal pinch_detected(scale: float)
signal long_press_detected(position: Vector2)

var _impl: Node = null

func _ready() -> void:
	if _is_arm_device():
		_impl = preload("touch_input_arm64.gd").new()
		_impl.name = "TouchImplARM64"
	else:
		_impl = preload("touch_input_x86_64.gd").new()
		_impl.name = "TouchImplX86_64"
	add_child(_impl)

	_impl.touch_started.connect(func(pos): touch_started.emit(pos))
	_impl.touch_ended.connect(func(pos): touch_ended.emit(pos))
	_impl.touch_moved.connect(func(pos): touch_moved.emit(pos))
	_impl.swipe_detected.connect(func(dir, vel): swipe_detected.emit(dir, vel))
	_impl.pinch_detected.connect(func(scale): pinch_detected.emit(scale))
	_impl.long_press_detected.connect(func(pos): long_press_detected.emit(pos))

func _is_arm_device() -> bool:
	if OS.has_feature("android") or OS.has_feature("ios"):
		return true
	var proc := OS.get_processor_name().to_lower()
	if proc.begins_with("arm") or proc.begins_with("aarch64"):
		return true
	return false

func is_touching() -> bool:
	return _impl.is_touching()

func get_touch_count() -> int:
	return _impl.get_touch_count()

func get_primary_touch_position() -> Vector2:
	return _impl.get_primary_touch_position()
