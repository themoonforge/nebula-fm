extends Node2D

# TODO create song resource
@export var songs: Array[SongResource] = []

#const RADIO_SONG_2_MIDI: String = "midi/song_2_midi.mid"
#const RADIO_SONG_2_MIX: String = "midi/song_2_mix.wav"
#
#const RADIO_SONG_3_MIDI: String = ""
#const RADIO_SONG_3_MIX: String = ""

signal play_radio_song(song_key: String)

func _ready():
	play_radio_song.connect(_on_play_radio_song)
	#play_radio_song.emit("cosmic_cookies")

func _on_play_radio_song(key: String):
	for song in songs:
		if song.song_key == key:
			%WorldAudioPlayer.stream = song.stream
			%WorldAudioPlayer.play()
			return	

func _unhandled_input(event: InputEvent) -> void:
	if event and event is InputEventKey and event.is_pressed() and event.keycode == KEY_M:
		play_radio_song.emit("cosmic_cookies")
		
