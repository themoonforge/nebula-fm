class_name NextOnAirSongElement extends HBoxContainer

@onready var song_cover: TextureRect = %SongCover
@onready var song_label: Label = %SongLabel
@onready var keys_label: RichTextLabel = %SongKeysLabel

var song: SongResource

func set_up(_song: SongResource) -> void:
	song = _song
	song_label.text = _song.song_title
	keys_label.text = ""
	song_cover.texture = _song.song_cover
