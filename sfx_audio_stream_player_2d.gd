extends Node

@onready var sfx_player: AudioStreamPlayer2D = $SFXPlayer
@onready var radio_station_player: AudioStreamPlayer2D = $RadioStationPlayer

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

@export var songs: Array[SongResource] = []

func play_sfx(sfx_name: String):
	sfx_player.stream = sfx_sounds[sfx_name]
	sfx_player.play()

func play_radio_song(song_name: String):
	#for song in songs:
		#if song.song_key == song_name:
			#radio_station_player.stream = song.stream
			#radio_station_player.play()
	radio_station_player.stream = radio_songs[song_name]
	radio_station_player.play()

func _unhandled_input(event: InputEvent) -> void:
	if event and event is InputEventKey and event.is_pressed() and event.keycode == KEY_M:
		play_radio_song("cosmic_cookies")
