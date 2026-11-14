extends Node2D

const PLAYER_SCENE := "res://Scenes/Sources/platformer/Character/player.tscn"
const STORY_SCENE := "res://Scenes/Campaign/Story.tscn"
const ENDING_SCENE := "res://Scenes/Campaign/Ending.tscn"
const SHARDS_PER_CHAPTER := 3
const GROUND_TOP := 620.0

const CHAPTERS := [
	{
		"title": "THE LANTERN GARDEN",
		"memory": "A voice from the shard: \"I hid the stars so the shadow could not follow their light.\"",
		"sky": "#111c2c",
		"accent": "#ffd878",
		"platforms": [
			[360, 510, 190, 24], [630, 460, 190, 24], [900, 510, 190, 24],
			[1170, 460, 190, 24], [1440, 510, 190, 24], [1710, 460, 190, 24],
			[1980, 510, 190, 24], [2250, 460, 190, 24]
		],
		"shards": [[360, 470], [1170, 420], [1980, 470]]
	},
	{
		"title": "THE BELL TOWER",
		"memory": "The bell's echo answers: \"The seal is failing. I could not ask the city to carry this alone.\"",
		"sky": "#182034",
		"accent": "#a9d8ff",
		"platforms": [
			[300, 530, 190, 24], [540, 480, 190, 24], [780, 430, 190, 24],
			[1020, 480, 190, 24], [1260, 430, 190, 24], [1500, 480, 190, 24],
			[1740, 430, 190, 24], [1980, 480, 190, 24], [2220, 430, 190, 24]
		],
		"shards": [[780, 390], [1500, 440], [2220, 390]]
	},
	{
		"title": "THE LAST OBSERVATORY",
		"memory": "The atlas reveals the truth: the Keeper stayed behind to hold the seal. The choice of what happens next is yours.",
		"sky": "#201b35",
		"accent": "#e6b9ff",
		"platforms": [
			[360, 510, 190, 24], [630, 460, 190, 24], [900, 510, 190, 24],
			[1170, 460, 190, 24], [1440, 510, 190, 24], [1710, 460, 190, 24],
			[1980, 510, 190, 24], [2250, 460, 190, 24]
		],
		"shards": [[630, 420], [1440, 470], [2250, 420]]
	}
]

var chapter_index: int
var chapter_data: Dictionary
var player: CharacterBody2D
var portal_area: Area2D
var portal_glow: Polygon2D
var shard_counter: Label
var status_label: Label
var collected_shards: int = 0
var transitioning: bool = false
var world_width: float = 2600.0


func _ready() -> void:
	chapter_index = CampaignState.chapter_index
	if not CampaignState.campaign_started or chapter_index >= CHAPTERS.size():
		push_error("A campaign chapter was opened without an active journey.")
		SceneRouter.return_to_hub()
		return

	chapter_data = CHAPTERS[chapter_index]
	_build_background()
	_add_ground()
	for platform_data in chapter_data["platforms"]:
		_add_platform(platform_data)
	for shard_data in chapter_data["shards"]:
		_add_shard(Vector2(float(shard_data[0]), float(shard_data[1])))
	_add_gate()
	_spawn_player()
	_build_hud()
	_update_hud()


func _build_background() -> void:
	var sky := Polygon2D.new()
	sky.polygon = PackedVector2Array([
		Vector2(-800, -500), Vector2(world_width + 800, -500),
		Vector2(world_width + 800, 1400), Vector2(-800, 1400)
	])
	sky.color = Color(str(chapter_data["sky"]))
	add_child(sky)

	var distant_hills := Polygon2D.new()
	distant_hills.polygon = PackedVector2Array([
		Vector2(-100, 620), Vector2(180, 400), Vector2(420, 540),
		Vector2(760, 340), Vector2(1080, 560), Vector2(1430, 390),
		Vector2(1740, 550), Vector2(2080, 350), Vector2(world_width + 300, 600),
		Vector2(world_width + 300, 760), Vector2(-100, 760)
	])
	distant_hills.color = Color("#26354b")
	add_child(distant_hills)

	var nearer_hills := Polygon2D.new()
	nearer_hills.polygon = PackedVector2Array([
		Vector2(-100, 640), Vector2(260, 530), Vector2(620, 625),
		Vector2(940, 490), Vector2(1280, 625), Vector2(1640, 510),
		Vector2(1970, 620), Vector2(2260, 500), Vector2(world_width + 300, 620),
		Vector2(world_width + 300, 760), Vector2(-100, 760)
	])
	nearer_hills.color = Color("#1b2b3c")
	add_child(nearer_hills)

	for index in range(42):
		var star := Polygon2D.new()
		var x := 35.0 + float(index) * 63.0
		var y := 55.0 + float((index * 71 + chapter_index * 39) % 330)
		star.position = Vector2(x, y)
		star.polygon = PackedVector2Array([
			Vector2(0, -2.5), Vector2(1.5, 0), Vector2(0, 2.5), Vector2(-1.5, 0)
		])
		star.color = Color("#e8e4cc")
		add_child(star)


func _add_ground() -> void:
	var ground := StaticBody2D.new()
	ground.position = Vector2(world_width / 2.0, GROUND_TOP + 60.0)
	var ground_size := Vector2(world_width + 1500.0, 120.0)
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = ground_size
	collision.shape = shape
	ground.add_child(collision)

	var ground_visual := Polygon2D.new()
	ground_visual.polygon = _rectangle_points(ground_size)
	ground_visual.color = Color("#283d42")
	ground.add_child(ground_visual)
	add_child(ground)

	var top_edge := Polygon2D.new()
	top_edge.position = Vector2(world_width / 2.0, GROUND_TOP + 3.0)
	top_edge.polygon = _rectangle_points(Vector2(world_width + 1500.0, 6.0))
	top_edge.color = Color(str(chapter_data["accent"]))
	add_child(top_edge)
	_add_boundary(-40.0)
	_add_boundary(world_width + 40.0)


func _add_boundary(x_position: float) -> void:
	var boundary := StaticBody2D.new()
	boundary.position = Vector2(x_position, 400.0)
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(80.0, 1800.0)
	collision.shape = shape
	boundary.add_child(collision)
	add_child(boundary)


func _add_platform(platform_data: Array) -> void:
	var center := Vector2(float(platform_data[0]), float(platform_data[1]))
	var size := Vector2(float(platform_data[2]), float(platform_data[3]))
	var platform := StaticBody2D.new()
	platform.position = center

	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = size
	collision.shape = shape
	platform.add_child(collision)

	var body := Polygon2D.new()
	body.polygon = _rectangle_points(size)
	body.color = Color("#40576b")
	platform.add_child(body)

	var highlight := Polygon2D.new()
	highlight.position = Vector2(0, -size.y / 2.0 + 2.0)
	highlight.polygon = _rectangle_points(Vector2(size.x, 4.0))
	highlight.color = Color(str(chapter_data["accent"]))
	platform.add_child(highlight)
	add_child(platform)


func _add_shard(shard_position: Vector2) -> void:
	var shard := Area2D.new()
	shard.position = shard_position
	shard.set_collision_layer_value(1, false)

	var collision := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 22.0
	collision.shape = shape
	shard.add_child(collision)

	var aura := Polygon2D.new()
	aura.polygon = _star_points(22.0, 10.0)
	aura.color = Color(str(chapter_data["accent"]), 0.26)
	shard.add_child(aura)

	var core := Polygon2D.new()
	core.polygon = _star_points(13.0, 6.0)
	core.color = Color(str(chapter_data["accent"]))
	shard.add_child(core)

	shard.body_entered.connect(_on_shard_entered.bind(shard))
	add_child(shard)


func _add_gate() -> void:
	portal_area = Area2D.new()
	portal_area.position = Vector2(world_width - 110.0, GROUND_TOP - 42.0)
	portal_area.set_collision_layer_value(1, false)

	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(64.0, 110.0)
	collision.shape = shape
	portal_area.add_child(collision)

	portal_glow = Polygon2D.new()
	portal_glow.polygon = PackedVector2Array([
		Vector2(0, -58), Vector2(32, -28), Vector2(32, 28),
		Vector2(0, 58), Vector2(-32, 28), Vector2(-32, -28)
	])
	portal_glow.color = Color("#596476")
	portal_area.add_child(portal_glow)

	var center := Polygon2D.new()
	center.polygon = PackedVector2Array([
		Vector2(0, -43), Vector2(20, -22), Vector2(20, 22),
		Vector2(0, 43), Vector2(-20, 22), Vector2(-20, -22)
	])
	center.color = Color("#101827")
	portal_area.add_child(center)

	var label := Label.new()
	label.position = Vector2(-92, -98)
	label.size = Vector2(184, 28)
	label.text = "THE STAR GATE"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", Color("#f0d99b"))
	portal_area.add_child(label)

	portal_area.body_entered.connect(_on_gate_entered)
	add_child(portal_area)


func _spawn_player() -> void:
	var packed_player := load(PLAYER_SCENE) as PackedScene
	if packed_player == null:
		push_error("Could not load the campaign player scene.")
		SceneRouter.return_to_hub()
		return

	player = packed_player.instantiate() as CharacterBody2D
	if player == null:
		push_error("The campaign player scene root is not a CharacterBody2D.")
		SceneRouter.return_to_hub()
		return

	player.position = Vector2(120.0, GROUND_TOP - 36.0)
	add_child(player)
	var camera := player.get_node_or_null("Camera2D") as Camera2D
	if camera != null:
		camera.make_current()


func _build_hud() -> void:
	var canvas := CanvasLayer.new()
	canvas.layer = 10
	add_child(canvas)

	var hud := Control.new()
	hud.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(hud)

	var panel := PanelContainer.new()
	panel.position = Vector2(24, 20)
	panel.custom_minimum_size = Vector2(430, 0)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color("#101827", 0.88)
	panel_style.border_color = Color("#8296b5")
	panel_style.set_border_width_all(1)
	panel_style.set_corner_radius_all(8)
	panel.add_theme_stylebox_override("panel", panel_style)
	panel.add_theme_constant_override("margin_left", 16)
	panel.add_theme_constant_override("margin_right", 16)
	panel.add_theme_constant_override("margin_top", 12)
	panel.add_theme_constant_override("margin_bottom", 12)
	hud.add_child(panel)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 5)
	panel.add_child(content)

	var title := Label.new()
	title.text = "CHAPTER %d - %s" % [chapter_index + 1, str(chapter_data["title"])]
	title.add_theme_color_override("font_color", Color(str(chapter_data["accent"])))
	content.add_child(title)

	var objective := Label.new()
	objective.text = "Find all three star shards, then reach the gate."
	objective.add_theme_color_override("font_color", Color("#e1e7f0"))
	content.add_child(objective)

	shard_counter = Label.new()
	shard_counter.add_theme_color_override("font_color", Color("#c4cee0"))
	content.add_child(shard_counter)

	status_label = Label.new()
	status_label.custom_minimum_size = Vector2(390, 34)
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.add_theme_color_override("font_color", Color("#b8c5d8"))
	content.add_child(status_label)

	var controls := Label.new()
	controls.position = Vector2(24, 674)
	controls.size = Vector2(620, 24)
	controls.text = "Move: A / D or arrows     Jump: Space     Title: Esc"
	controls.add_theme_color_override("font_color", Color("#e1e7f0"))
	hud.add_child(controls)


func _on_shard_entered(body: Node2D, shard: Area2D) -> void:
	if body != player or not is_instance_valid(shard):
		return

	shard.set_deferred("monitoring", false)
	shard.queue_free()
	collected_shards += 1
	_update_hud()
	status_label.text = str(chapter_data["memory"])

	if collected_shards == SHARDS_PER_CHAPTER and portal_area.overlaps_body(player):
		_on_gate_entered(player)


func _on_gate_entered(body: Node2D) -> void:
	if body != player or transitioning:
		return
	if collected_shards < SHARDS_PER_CHAPTER:
		status_label.text = "The gate is dim. It needs all three star shards."
		return

	transitioning = true
	portal_glow.color = Color(str(chapter_data["accent"]))
	CampaignState.complete_chapter()
	if CampaignState.campaign_complete:
		SceneRouter.open_scene(ENDING_SCENE)
	else:
		SceneRouter.open_scene(STORY_SCENE)


func _update_hud() -> void:
	if is_instance_valid(shard_counter):
		shard_counter.text = "Star shards: %d / %d" % [collected_shards, SHARDS_PER_CHAPTER]
	if is_instance_valid(portal_glow) and collected_shards >= SHARDS_PER_CHAPTER:
		portal_glow.color = Color(str(chapter_data["accent"]))
	if is_instance_valid(status_label) and status_label.text.is_empty():
		status_label.text = "The atlas points east. Keep moving."


func _rectangle_points(size: Vector2) -> PackedVector2Array:
	var half_size := size / 2.0
	return PackedVector2Array([
		Vector2(-half_size.x, -half_size.y),
		Vector2(half_size.x, -half_size.y),
		Vector2(half_size.x, half_size.y),
		Vector2(-half_size.x, half_size.y)
	])


func _star_points(outer_radius: float, inner_radius: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	for index in range(10):
		var radius := outer_radius if index % 2 == 0 else inner_radius
		var angle := -PI / 2.0 + PI * float(index) / 5.0
		points.append(Vector2(cos(angle), sin(angle)) * radius)
	return points
