extends Control

const LEVEL_SCENE := "res://Scenes/Campaign/Level.tscn"
const CHAPTER_TITLES := [
	"The Lantern Garden",
	"The Bell Tower",
	"The Last Observatory"
]

var page_index: int = 0
var pages: Array[String] = []
var chapter_label: Label
var story_label: Label
var page_label: Label
var next_button: Button


func _ready() -> void:
	if not CampaignState.campaign_started or CampaignState.chapter_index >= CHAPTER_TITLES.size():
		push_error("The story scene was opened without an active chapter.")
		SceneRouter.return_to_hub()
		return

	pages = _pages_for_chapter(CampaignState.chapter_index)
	_build_interface()
	_show_page()


func _pages_for_chapter(chapter: int) -> Array[String]:
	match chapter:
		0:
			return [
				"On the night the stars vanished over Luma, the old observatory went dark. The city woke beneath a blank sky.",
				"You are Neri, an apprentice mapmaker. A brass atlas opens to a new page: three star shards lie along the old sky road. The Keeper hid them for a reason.",
				"A note in the atlas reads: \"The dark between stars is moving. Light can guide it home, or hold it back.\" Find the three shards, then reach the gate."
			]
		1:
			return [
				"The first shard carries a memory: the Keeper broke the constellations to seal a shadow tide. The light was hidden to keep the darkness from following it.",
				"The bell tower can guide the next shard back to the atlas. Find three more, then follow the sound to the gate."
			]
		2:
			return [
				"The tower's last note reveals the Keeper is still holding the seal alone. The final three shards are waiting in the observatory.",
				"When the atlas is whole, you will choose: share the light and the burden, or keep the seal closed as it is."
			]
		_:
			push_error("Unknown chapter index: %d" % chapter)
			return []


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

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 18)
	panel.add_child(content)

	var title := Label.new()
	title.text = "THE STARLESS ATLAS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 34)
	title.add_theme_color_override("font_color", Color("#f0d99b"))
	content.add_child(title)

	chapter_label = Label.new()
	chapter_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	chapter_label.add_theme_color_override("font_color", Color("#9fc4dc"))
	content.add_child(chapter_label)

	story_label = Label.new()
	story_label.custom_minimum_size = Vector2(620, 180)
	story_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	story_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	story_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	story_label.add_theme_font_size_override("font_size", 21)
	story_label.add_theme_color_override("font_color", Color("#e1e7f0"))
	content.add_child(story_label)

	page_label = Label.new()
	page_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	page_label.add_theme_color_override("font_color", Color("#aab8cc"))
	content.add_child(page_label)

	next_button = Button.new()
	next_button.custom_minimum_size = Vector2(0, 48)
	next_button.add_theme_font_size_override("font_size", 18)
	next_button.pressed.connect(_advance)
	content.add_child(next_button)

	var hint := Label.new()
	hint.text = "A / D or arrows to move   |   Space to jump   |   Esc to title"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_color_override("font_color", Color("#aab8cc"))
	content.add_child(hint)


func _show_page() -> void:
	chapter_label.text = "CHAPTER %d - %s" % [
		CampaignState.chapter_index + 1,
		CHAPTER_TITLES[CampaignState.chapter_index].to_upper()
	]
	story_label.text = pages[page_index]
	page_label.text = "Page %d of %d" % [page_index + 1, pages.size()]
	next_button.text = "Enter %s" % CHAPTER_TITLES[CampaignState.chapter_index] if page_index == pages.size() - 1 else "Continue"


func _advance() -> void:
	if page_index < pages.size() - 1:
		page_index += 1
		_show_page()
	else:
		SceneRouter.open_scene(LEVEL_SCENE)
