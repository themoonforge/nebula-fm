class_name NextOnAirComponent extends BuildingUiComponent

@export var song_element: PackedScene
@onready var next_on_air_container = %NextOnAirContainer

var required_radio_song_element: NextOnAirSongElement
var required_radio_song_keys_text: String
var required_radio_song_keys: Array[int]

func _ready() -> void:
	MusicPlayer.active_radio_keys_updated.connect(_on_active_radio_keys_updated)
	MusicPlayer.change_required_radio_song.connect(_on_change_required_radio_song)
	
	for song in MusicPlayer.songs:
		var song_element_instance: NextOnAirSongElement = song_element.instantiate()
		next_on_air_container.add_child(song_element_instance)
		song_element_instance.set_up(MusicPlayer.songs[song])

func set_up(_building: Building) -> void:
	super._set_up(_building)
	#building.note_produced.connect(_on_note_produced)

func _on_active_radio_keys_updated(song: SongResource, keys: Array[int]) -> void:
	var formatted_keys_label_text = generate_bbcode_string(required_radio_song_keys, keys)
	required_radio_song_element.keys_label.text = formatted_keys_label_text
	
func _on_change_required_radio_song(song: SongResource, midi_keys: Array[int]) -> void:
	for element in next_on_air_container.get_children():
		if element is not NextOnAirSongElement:
			continue
			
		if element.song != song:
			continue
		
		required_radio_song_keys = midi_keys
		required_radio_song_element = element
		required_radio_song_keys_text = initial_format_keys_as_text(midi_keys)
		required_radio_song_element.keys_label.text = required_radio_song_keys_text
		next_on_air_container.move_child(required_radio_song_element, 0)
		
func initial_format_keys_as_text(midi_keys: Array[int]) -> String:
	var text_keys: String
	
	for key in midi_keys:
		var key_text = MidiUtility.key_number_to_note_name_flat_up(key)
		text_keys += key_text + ", "
		
	text_keys.trim_suffix(",")
		
	return text_keys
	
func generate_bbcode_string(current_keys: Array[int], required_keys: Array[int]) -> String:
	var required_note_counts: Dictionary[String, int] = {}
	for key in required_keys:
		var note_name = MidiUtility.key_number_to_note_name_flat_up(key)
		if required_note_counts.has(note_name):
			required_note_counts[note_name] += 1
		else:
			required_note_counts[note_name] = 1
	
	var matched_counts: Dictionary[String, int] = {}
	
	var result = ""
	for i in range(current_keys.size()):
		var key = current_keys[i]
		var key_str = MidiUtility.key_number_to_note_name_flat_up(key)
		
		var should_bold = false
		if required_note_counts.has(key_str):
			if not matched_counts.has(key_str):
				matched_counts[key_str] = 0
			
			if matched_counts[key_str] < required_note_counts[key_str]:
				should_bold = true
				matched_counts[key_str] += 1
		
		if should_bold:
			key_str = "[color=black]" + key_str + "[/color]"
		
		result += key_str
		
		if i < current_keys.size() - 1:
			result += ", "
	
	return result

		
	#for rect in next_on_air_container.get_children():
		#rect.queue_free()
	
	#for key in midi_keys:
		#var texture: Texture = NotePackageTextures.get_texture_for_key(key)
		#var texture_rect: TextureRect = TextureRect.new()
		#texture_rect.texture = texture
		#next_on_air_container.add_child(texture_rect)

#func update() -> void:
	#for i in building.building_resource.input_locations.size():
		#var note_package: NotePackage = building.input_buffer.read_first_note_from_buffer(i)
		#
		#if !note_package:
			#continue
		#
		#if note_package.key_numbers.size() == 0:
			#continue
			#
		#render_note_textures(note_package, input_note_texture_rect)
