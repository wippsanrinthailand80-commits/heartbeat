extends Node

var current_scene_path: String = ""
var scene_stack: Array[String] = []

func _ready() -> void:
	pass

func change_scene(path: String, transition: String = "fade") -> void:
	if path == current_scene_path:
		return

	EventBus.scene_transition_started.emit(path)

	match transition:
		"fade":
			await TransitionManager.fade_to_black(0.5)
		"dissolve":
			await TransitionManager.dissolve_transition(1.0)
		"instant":
			pass
		_:
			await TransitionManager.fade_to_black(0.5)

	var error := get_tree().change_scene_to_file(path)
	if error != OK:
		push_error("SceneManager: Failed to change scene to: %s" % path)
		return

	current_scene_path = path

	match transition:
		"fade", "dissolve":
			await TransitionManager.fade_from_black(0.5)
		"instant":
			pass
		_:
			await TransitionManager.fade_from_black(0.5)

	EventBus.scene_transition_finished.emit(path)

func push_scene(path: String) -> void:
	scene_stack.append(current_scene_path)
	await change_scene(path)

func pop_scene() -> void:
	if scene_stack.is_empty():
		push_warning("SceneManager: Scene stack is empty")
		return
	var previous: String = scene_stack.pop_back()
	await change_scene(previous, "instant")

func get_current_scene() -> String:
	return current_scene_path

func get_scene_stack() -> Array[String]:
	return scene_stack.duplicate()
