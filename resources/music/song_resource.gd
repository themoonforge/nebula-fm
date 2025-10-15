class_name SongResource extends Resource

@export var song_title: String
@export var song_key: StringName
@export var song_cover: Texture

@export var melody_midi_path: String # .midi file!
@export var mix_path: String # .wav file!

#var stream: AudioStreamWAV
#
#func _init() -> void:
	#stream = AudioStreamWAV.load_from_file(mix_path)
