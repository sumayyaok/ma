extends Control

const STORY_SCENE := "res://Scenes/Campaign/Story.tscn"
const ENDING_SCENE := "res://Scenes/Campaign/Ending.tscn"

var track_label: Label
var music_button: Button


func _ready() -> void:
	_build_interface()
	MusicManager.track_changed.connect(_refresh_music_controls)
	_refresh_music_controls()


func _build_interface() -> void:
	var background := ColorRect.new()
	background.color = Color("#0c1421")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(720, 0)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color("#19263a")
	panel_style.border_color = Color("#8296b5")
	panel_style.set_border_width_all(1)
	panel_style.set_corner_radius_all(16)
	panel.add_theme_stylebox_override("panel", panel_style)
	panel.add_theme_constant_override("margin_left", 36)
	panel.add_theme_constant_override("margin_right", 36)
	panel.add_theme_constant_override("margin_top", 30)
	panel.add_theme_constant_override("margin_bottom", 28)
	center.add_child(panel)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 14)
	panel.add_child(content)

	var title := Label.new()
	title.text = "THE STARLESS ATLAS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 38)
	title.add_theme_color_override("font_color", Color("#f0d99b"))
	content.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "A story of a broken sky, three lost lights, and the choice of what to do with them."
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	subtitle.add_theme_font_size_override("font_size", 18)
	subtitle.add_theme_color_override("font_color", Color("#d1d9e7"))
	content.add_child(subtitle)

	var separator := HSeparator.new()
	content.add_child(separator)

	var premise := Label.new()
	premise.text = "You are Neri, an apprentice mapmaker. Cross the old sky road, recover three star shards in each chapter, and uncover why the Keeper hid them."
	premise.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	premise.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	premise.add_theme_color_override("font_color", Color("#b8c5d8"))
	content.add_child(premise)

	if CampaignState.campaign_started and not CampaignState.campaign_complete:
		var chapter_number := CampaignState.chapter_index + 1
		_add_action_button(content, "Continue - Chapter %d of 3" % chapter_number, _continue_campaign)
	if CampaignState.campaign_complete:
		_add_action_button(content, "Review Your Ending", _review_ending)
	_add_action_button(content, "Begin a New Journey", _start_new_campaign)

	var controls := Label.new()
	controls.text = "Move: A / D or arrow keys    Jump: Space    Return to title: Esc"
	controls.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	controls.add_theme_color_override("font_color", Color("#aab8cc"))
	content.add_child(controls)

	var music_separator := HSeparator.new()
	content.add_child(music_separator)

	track_label = Label.new()
	track_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	track_label.add_theme_color_override("font_color", Color("#c4cee0"))
	content.add_child(track_label)

	var music_controls := HBoxContainer.new()
	music_controls.alignment = BoxContainer.ALIGNMENT_CENTER
	music_controls.add_theme_constant_override("separation", 10)
	content.add_child(music_controls)

	var previous_button := Button.new()
	previous_button.text = "Previous Track"
	previous_button.pressed.connect(MusicManager.previous_track)
	music_controls.add_child(previous_button)

	music_button = Button.new()
	music_button.pressed.connect(_toggle_music)
	music_controls.add_child(music_button)

	var next_button := Button.new()
	next_button.text = "Next Track"
	next_button.pressed.connect(MusicManager.next_track)
	music_controls.add_child(next_button)


func _add_action_button(parent: VBoxContainer, title: String, action: Callable) -> void:
	var button := Button.new()
	button.text = title
	button.custom_minimum_size = Vector2(0, 48)
	button.add_theme_font_size_override("font_size", 19)
	button.pressed.connect(action)
	parent.add_child(button)


func _start_new_campaign() -> void:
	CampaignState.start_new_campaign()
	SceneRouter.open_scene(STORY_SCENE)


func _continue_campaign() -> void:
	if CampaignState.campaign_complete:
		_review_ending()
	else:
		SceneRouter.open_scene(STORY_SCENE)


func _review_ending() -> void:
	SceneRouter.open_scene(ENDING_SCENE)


func _toggle_music() -> void:
	MusicManager.toggle_music()
	_refresh_music_controls()


func _refresh_music_controls(_track_name: String = "") -> void:
	if not is_instance_valid(track_label) or not is_instance_valid(music_button):
		return
	track_label.text = "Soundtrack: %s" % MusicManager.current_track_name()
	music_button.text = "Music: On" if MusicManager.music_enabled else "Music: Off"
