extends Control

const TITLE_SCENE := "res://Hub.tscn"

var content: VBoxContainer


func _ready() -> void:
	if not CampaignState.campaign_complete:
		push_error("The ending was opened before the final chapter was completed.")
		SceneRouter.return_to_hub()
		return
	_build_interface()
	if CampaignState.ending_choice.is_empty():
		_show_choice()
	else:
		_show_result()


func _build_interface() -> void:
	var background := ColorRect.new()
	background.color = Color("#0c1421")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(760, 0)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color("#19263a")
	panel_style.border_color = Color("#8296b5")
	panel_style.set_border_width_all(1)
	panel_style.set_corner_radius_all(16)
	panel.add_theme_stylebox_override("panel", panel_style)
	panel.add_theme_constant_override("margin_left", 42)
	panel.add_theme_constant_override("margin_right", 42)
	panel.add_theme_constant_override("margin_top", 36)
	panel.add_theme_constant_override("margin_bottom", 36)
	center.add_child(panel)

	content = VBoxContainer.new()
	content.add_theme_constant_override("separation", 18)
	panel.add_child(content)


func _show_choice() -> void:
	_clear_content()
	_add_title("THE ATLAS IS WHOLE")
	_add_story("The Keeper's voice comes through the final shard. The sky can return, but the seal was never meant to be held by one person. What will Neri do with the light?")
	_add_button("Share the light", _choose_shared_light)
	_add_button("Keep the seal", _choose_seal)


func _choose_shared_light() -> void:
	CampaignState.choose_ending("share_the_light")
	_show_result()


func _choose_seal() -> void:
	CampaignState.choose_ending("keep_the_seal")
	_show_result()


func _show_result() -> void:
	_clear_content()
	_add_title("THE STARLESS ATLAS")
	if CampaignState.ending_choice == "share_the_light":
		_add_story("Neri divides the shards among the city's lanterns. The stars return, the seal stays closed, and the Keeper steps out of the observatory. For the first time, no one has to guard the dark alone.")
	else:
		_add_story("Neri returns the shards to the seal. The sky remains dark, but the Keeper is no longer alone: the city takes turns keeping watch while the atlas searches for another way.")
	_add_story("The road ends here. The map is no longer blank.")
	_add_button("Return to the title", _return_to_title)


func _clear_content() -> void:
	for child in content.get_children():
		child.queue_free()


func _add_title(text: String) -> void:
	var title := Label.new()
	title.text = text
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 34)
	title.add_theme_color_override("font_color", Color("#f0d99b"))
	content.add_child(title)


func _add_story(text: String) -> void:
	var story := Label.new()
	story.text = text
	story.custom_minimum_size = Vector2(620, 110)
	story.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	story.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	story.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	story.add_theme_font_size_override("font_size", 21)
	story.add_theme_color_override("font_color", Color("#e1e7f0"))
	content.add_child(story)


func _add_button(text: String, action: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(0, 48)
	button.add_theme_font_size_override("font_size", 18)
	button.pressed.connect(action)
	content.add_child(button)


func _return_to_title() -> void:
	SceneRouter.open_scene(TITLE_SCENE)
