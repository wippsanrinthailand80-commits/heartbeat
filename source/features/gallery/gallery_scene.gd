extends Control

@onready var grid_container: GridContainer = $Panel/Margin/VBox/ScrollContainer/GridContainer
@onready var title_label: Label = $Panel/TitleLabel
@onready var back_button: Button = $Panel/Margin/VBox/BackButton
@onready var preview_panel: PanelContainer = $PreviewPanel
@onready var preview_texture: TextureRect = $PreviewPanel/TextureRect
@onready var cg_title_label: Label = $PreviewPanel/TitleLabel
@onready var preview_close_button: Button = $PreviewPanel/CloseButton

func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)
	preview_close_button.pressed.connect(_on_preview_close)
	preview_panel.visible = false
	_populate_gallery()

func _input(event: InputEvent) -> void:
	if preview_panel.visible and event is InputEventScreenTouch and event.pressed:
		if not preview_panel.get_global_rect().has_point(event.position):
			_on_preview_close()
			get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel"):
		if preview_panel.visible:
			_on_preview_close()
		else:
			SceneManager.pop_scene()
		get_viewport().set_input_as_handled()

func _on_preview_close() -> void:
	preview_panel.visible = false

func _populate_gallery() -> void:
	for child in grid_container.get_children():
		child.queue_free()

	var all_cgs: Array = GalleryManager.get_all_cgs()

	if all_cgs.is_empty():
		var label := Label.new()
		label.text = "No CGs registered. Add CG data to data/gallery.json"
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		grid_container.add_child(label)
		return

	for cg in all_cgs:
		var cg_id: String = cg.get("id", "")
		var is_unlocked: bool = GalleryManager.is_cg_unlocked(cg_id)

		var button := Button.new()
		button.custom_minimum_size = Vector2(200, 150)

		if is_unlocked and ResourceLoader.exists(cg.get("path", "")):
			var tex := TextureRect.new()
			tex.texture = load(cg["path"])
			tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			button.add_child(tex)
		else:
			button.text = "???"

		button.pressed.connect(_on_cg_pressed.bind(cg))
		grid_container.add_child(button)

func _on_cg_pressed(cg: Dictionary) -> void:
	var path: String = cg.get("path", "")
	if ResourceLoader.exists(path):
		preview_panel.visible = true
		preview_texture.texture = load(path)
		cg_title_label.text = cg.get("title", cg.get("id", ""))

func _on_back_pressed() -> void:
	SceneManager.pop_scene()
