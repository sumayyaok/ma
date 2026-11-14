extends AudioStreamPlayer

signal track_changed(track_name: String)

const TRACKS: Array[Dictionary] = [
	{
		"name": "Ambient Theme",
		"path": "res://Audio/youtube-audio-3.mp3"
	},
	{
		"name": "Castle Theme",
		"path": "res://Scenes/Sources/castle_battle/youtube-audio 2 (1).mp3"
	},
	{
		"name": "Adventure Theme",
		"path": "res://Scenes/Sources/adventure/harry-potter's-adventure-1/youtube-audio.mp3"
	}
]

var current_track_index: int = -1
var music_enabled: bool = true


func _ready() -> void:
	bus = "music"
	volume_db = -8.0
	play_track(0)


func play_track(index: int) -> void:
	current_track_index = posmod(index, TRACKS.size())
	var track: Dictionary = TRACKS[current_track_index]
	var track_path := str(track["path"])
	var loaded_stream := load(track_path) as AudioStreamMP3
	if loaded_stream == null:
		push_error("Could not load soundtrack: %s" % track_path)
		return

	loaded_stream.loop = true
	stream = loaded_stream
	if music_enabled:
		play()
	track_changed.emit(str(track["name"]))


func next_track() -> void:
	play_track(current_track_index + 1)


func previous_track() -> void:
	play_track(current_track_index - 1)


func toggle_music() -> void:
	music_enabled = not music_enabled
	stream_paused = not music_enabled
	if music_enabled and not playing:
		play()


func current_track_name() -> String:
	return str(TRACKS[current_track_index]["name"])
