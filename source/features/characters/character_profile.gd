class_name CharacterProfile
extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var color: Color = Color.WHITE
@export var portraits: Dictionary = {}
@export var default_emotion: String = "neutral"
@export var description: String = ""
@export var birthday: String = ""
@export var likes: Array = []
@export var dislikes: Array = []

func get_portrait_path(emotion: String = "neutral") -> String:
	if portraits.has(emotion):
		return portraits[emotion]
	if portraits.has(default_emotion):
		return portraits[default_emotion]
	return "res://assets/art/characters/placeholder.png"

func get_all_emotions() -> Array[String]:
	var emotions: Array[String] = []
	for key in portraits:
		emotions.append(key)
	return emotions

static func load_from_file(path: String) -> CharacterProfile:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("CharacterProfile: Failed to open: %s" % path)
		return null

	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK:
		push_error("CharacterProfile: Failed to parse: %s" % path)
		return null

	var data: Dictionary = json.data
	var profile := CharacterProfile.new()
	profile.id = data.get("id", "")
	profile.display_name = data.get("display_name", "")
	profile.color = Color.html(data.get("color", "#ffffff"))
	profile.portraits = data.get("portraits", {})
	profile.default_emotion = data.get("default_emotion", "neutral")
	profile.description = data.get("description", "")
	profile.birthday = data.get("birthday", "")
	profile.likes = data.get("likes", [])
	profile.dislikes = data.get("dislikes", [])
	return profile
