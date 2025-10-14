class_name Game extends Node

func _ready() -> void:
	print("share songs emitted")
	MusicPlayer.share_songs.emit(MusicPlayer.songs)
