extends Node

const HUB_SCENE := "res://Hub.tscn"


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		if get_tree().current_scene != null and get_tree().current_scene.scene_file_path != HUB_SCENE:
			return_to_hub()


func open_scene(scene_path: String) -> void:
	if not ResourceLoader.exists(scene_path, "PackedScene"):
		push_error("Scene does not exist: %s" % scene_path)
		return

	var error := get_tree().change_scene_to_file(scene_path)
	if error != OK:
		push_error("Could not open scene %s (error %d)." % [scene_path, error])


func return_to_hub() -> void:
	var error := get_tree().change_scene_to_file(HUB_SCENE)
	if error != OK:
		push_error("Could not return to the scene hub (error %d)." % error)
