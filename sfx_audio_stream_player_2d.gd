extends Node

@onready var sfx_player: AudioStreamPlayer2D = $SFXPlayer
@onready var radio_station_player: AudioStreamPlayer2D = $RadioStationPlayer

signal active_radio_keys_updated(song: SongResource, midi_keys: Array[int])
signal change_required_radio_song(song: SongResource, midi_keys: Array[int])
signal change_song(song: SongResource)
signal loop_finished(song: SongResource)
signal share_songs(songs: Dictionary[StringName, SongResource])

signal current_played_song(song: StringName)

var sfx_sounds = {
	"ui_click": preload("res://sfx/ui/ui_click.ogg"),
	"ui_click_pop": preload("res://sfx/ui/ui_click_pop.ogg"),
	"ui_click_tsk": preload("res://sfx/ui/ui_click_tsk.ogg"),
	"ui_click_confirm": preload("res://sfx/ui/ui_click_confirm.ogg"),
	"build_placed": preload("res://sfx/building/build_placed.ogg"),
}

var radio_songs = {
	"cosmic_cookies": preload("res://music/radio_songs/cosmic_cookies-mix.ogg"),
	"balance": preload("res://music/radio_songs/balance-mix.ogg")
}

var current_radio_song_key: String
var current_radio_song_plays: int
var last_radio_song_position: float = -1.0

@export var songs: Dictionary[StringName, SongResource] = {}

func play_sfx(sfx_name: String):
	sfx_player.stream = sfx_sounds[sfx_name]
	sfx_player.play()

func play_radio_song(song_key: String, loop_amount: int = 1):
	
	current_radio_song_key = song_key
	
	if radio_station_player.stream != radio_songs[song_key]:
		radio_station_player.stream = radio_songs[song_key]
	if !radio_station_player.playing:
		radio_station_player.play()
		
	var current_position = radio_station_player.get_playback_position()
	if current_position < last_radio_song_position:
		current_radio_song_plays += 1
		if current_radio_song_plays == loop_amount:
			MusicPlayer.loop_finished.emit(songs[current_radio_song_key])
			stop_radio_song()
	last_radio_song_position = current_position
	
	current_played_song.emit(song_key)
		
func play_current_radio_song() -> void:
	if current_radio_song_key.is_empty():
		return
		
	play_radio_song(current_radio_song_key)
	
func stop_radio_song():
	radio_station_player.stop()

func get_next_radio_song() -> String:
	var keys = radio_songs.keys()
	var index = keys.find(current_radio_song_key)
	
	if index >= keys.size() - 1:
		return ""
	
	return keys[index + 1]
