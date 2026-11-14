extends Node

const SAVE_PATH := "user://starless_atlas.cfg"
const LAST_CHAPTER := 2
const ENDING_CHOICES := ["share_the_light", "keep_the_seal"]

var chapter_index: int = 0
var campaign_started: bool = false
var campaign_complete: bool = false
var ending_choice: String = ""


func _ready() -> void:
	_load_progress()


func start_new_campaign() -> void:
	chapter_index = 0
	campaign_started = true
	campaign_complete = false
	ending_choice = ""
	_save_progress()


func complete_chapter() -> void:
	if not campaign_started or campaign_complete:
		push_error("Cannot complete a chapter before starting a campaign.")
		return

	if chapter_index >= LAST_CHAPTER:
		campaign_complete = true
		ending_choice = ""
	else:
		chapter_index += 1
	_save_progress()


func choose_ending(choice: String) -> void:
	if not campaign_complete or choice not in ENDING_CHOICES:
		push_error("Invalid campaign ending choice: %s" % choice)
		return

	ending_choice = choice
	_save_progress()


func _load_progress() -> void:
	var config := ConfigFile.new()
	var error := config.load(SAVE_PATH)
	if error == ERR_FILE_NOT_FOUND:
		return
	if error != OK:
		push_error("Could not load campaign progress (error %d)." % error)
		return

	var saved_chapter := int(config.get_value("campaign", "chapter_index", 0))
	if saved_chapter < 0 or saved_chapter > LAST_CHAPTER:
		push_warning("Saved chapter index is out of range; using the nearest valid chapter.")
	chapter_index = clampi(saved_chapter, 0, LAST_CHAPTER)
	campaign_started = bool(config.get_value("campaign", "campaign_started", false))
	campaign_complete = bool(config.get_value("campaign", "campaign_complete", false))
	ending_choice = str(config.get_value("campaign", "ending_choice", ""))
	if ending_choice not in ENDING_CHOICES:
		if not ending_choice.is_empty():
			push_warning("Saved ending choice is invalid; the ending choice will be shown again.")
		ending_choice = ""


func _save_progress() -> void:
	var config := ConfigFile.new()
	config.set_value("campaign", "chapter_index", chapter_index)
	config.set_value("campaign", "campaign_started", campaign_started)
	config.set_value("campaign", "campaign_complete", campaign_complete)
	config.set_value("campaign", "ending_choice", ending_choice)
	var error := config.save(SAVE_PATH)
	if error != OK:
		push_error("Could not save campaign progress (error %d)." % error)
