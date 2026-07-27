extends CanvasLayer

var overlay: ColorRect
var current_time: String = "morning"
var is_enabled: bool = true

const TIME_COLORS := {
	"morning": Color(1.0, 0.95, 0.8, 0.12),
	"afternoon": Color(1.0, 1.0, 1.0, 0.0),
	"evening": Color(1.0, 0.7, 0.4, 0.18),
	"night": Color(0.2, 0.25, 0.5, 0.30),
}

func _ready() -> void:
	layer = 10

	overlay = ColorRect.new()
	overlay.color = TIME_COLORS["morning"]
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.grow_horizontal = Control.GROW_DIRECTION_BOTH
	overlay.grow_vertical = Control.GROW_DIRECTION_BOTH
	add_child(overlay)

	EventBus.time_advanced.connect(_on_time_advanced)
	_apply_time_color(GameState.current_time_of_day)

func _on_time_advanced(_new_day: int, new_time: String) -> void:
	_apply_time_color(new_time)

func _apply_time_color(time: String) -> void:
	current_time = time
	if not is_enabled:
		overlay.color.a = 0.0
		return
	if not TIME_COLORS.has(time):
		overlay.color.a = 0.0
		return

	var target_color: Color = TIME_COLORS[time]
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(overlay, "color:r", target_color.r, 1.0)
	tween.tween_property(overlay, "color:g", target_color.g, 1.0)
	tween.tween_property(overlay, "color:b", target_color.b, 1.0)
	tween.tween_property(overlay, "color:a", target_color.a, 1.0)

func set_enabled(enabled: bool) -> void:
	is_enabled = enabled
	if not enabled:
		overlay.color.a = 0.0
	else:
		_apply_time_color(current_time)

func get_current_color() -> Color:
	return TIME_COLORS.get(current_time, Color.TRANSPARENT)
