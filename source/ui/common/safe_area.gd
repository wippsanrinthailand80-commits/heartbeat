extends Node

@export var target_margin: MarginContainer

func _ready() -> void:
	if not target_margin:
		target_margin = _find_first_margin(get_parent())
	if target_margin:
		_apply_safe_area()

func _apply_safe_area() -> void:
	var safe := DisplayServer.get_display_safe_area()
	var viewport_size := get_viewport().get_visible_rect().size

	var margin_left := int(safe.position.x)
	var margin_top := int(safe.position.y)
	var margin_right := int(viewport_size.x - safe.end.x)
	var margin_bottom := int(viewport_size.y - safe.end.y)

	target_margin.add_theme_constant_override("margin_left", max(margin_left, 0))
	target_margin.add_theme_constant_override("margin_top", max(margin_top, 0))
	target_margin.add_theme_constant_override("margin_right", max(margin_right, 0))
	target_margin.add_theme_constant_override("margin_bottom", max(margin_bottom, 0))

func _find_first_margin(node: Node) -> MarginContainer:
	if node is MarginContainer:
		return node
	for child in node.get_children():
		if child is MarginContainer:
			return child
	for child in node.get_children():
		var result := _find_first_margin(child)
		if result:
			return result
	return null
