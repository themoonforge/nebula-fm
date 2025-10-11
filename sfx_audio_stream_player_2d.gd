extends Node

@onready var sfx_player: AudioStreamPlayer2D = $SFXPlayer
@onready var radio_station_player: AudioStreamPlayer2D = $RadioStationPlayer

signal change_required_midi_key(midi_keys: Array[int])
signal change_song(song: Resource)

var sfx_sounds = {
	"ui_click": preload("res://sfx/ui/ui_click.ogg"),
	"ui_click_pop": preload("res://sfx/ui/ui_click_pop.ogg"),
	"ui_click_tsk": preload("res://sfx/ui/ui_click_tsk.ogg"),
	"ui_click_confirm": preload("res://sfx/ui/ui_click_confirm.ogg"),
	"build_placed": preload("res://sfx/building/build_placed.ogg"),
}

var radio_songs = {
	"cosmic_cookies": preload("res://midi/song_1_mix.wav")
}

@export var songs: Dictionary[StringName, SongResource] = {}

func play_sfx(sfx_name: String):
	sfx_player.stream = sfx_sounds[sfx_name]
	sfx_player.play()

func play_radio_song(song_name: String):
	if radio_station_player.stream != radio_songs[song_name]:
		radio_station_player.stream = radio_songs[song_name]
	if !radio_station_player.playing:
		radio_station_player.play()
	
func stop_radio_song():
	radio_station_player.stop()
