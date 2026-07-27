extends CanvasLayer

signal transition_completed

var is_transitioning: bool = false
var color_rect: ColorRect

func _ready() -> void:
	layer = 100

	color_rect = ColorRect.new()
	color_rect.color = Color(0, 0, 0, 1)
	color_rect.visible = false
	color_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	color_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	color_rect.grow_horizontal = Control.GROW_DIRECTION_BOTH
	color_rect.grow_vertical = Control.GROW_DIRECTION_BOTH
	add_child(color_rect)

func fade_to_black(duration: float = 0.5) -> void:
	if is_transitioning:
		return
	is_transitioning = true
	color_rect.visible = true
	color_rect.color = Color(0, 0, 0, 0)

	var tween := create_tween()
	tween.tween_property(color_rect, "color:a", 1.0, duration)
	await tween.finished

	is_transitioning = false
	transition_completed.emit()

func fade_from_black(duration: float = 0.5) -> void:
	if is_transitioning:
		return
	is_transitioning = true
	color_rect.visible = true
	color_rect.color = Color(0, 0, 0, 1)

	var tween := create_tween()
	tween.tween_property(color_rect, "color:a", 0.0, duration)
	await tween.finished

	color_rect.visible = false
	is_transitioning = false
	transition_completed.emit()

func fade_to_color(target_color: Color, duration: float = 0.5) -> void:
	if is_transitioning:
		return
	is_transitioning = true
	color_rect.visible = true
	color_rect.color = Color(target_color.r, target_color.g, target_color.b, 0)

	var tween := create_tween()
	tween.tween_property(color_rect, "color:a", 1.0, duration)
	await tween.finished

	is_transitioning = false
	transition_completed.emit()

func dissolve_transition(duration: float = 1.0) -> void:
	await fade_to_black(duration / 2.0)
	await fade_from_black(duration / 2.0)

func instant_black() -> void:
	color_rect.visible = true
	color_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	color_rect.color = Color(0, 0, 0, 1)

func instant_clear() -> void:
	color_rect.visible = false
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
