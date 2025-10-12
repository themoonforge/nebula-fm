@tool
class_name SpaceRadioResource extends AbstractBuildingResource

var required_midi_keys: Array[int] = []:
	set(value):
		required_midi_keys = value
		var simple: Array[StringName] = []
		for key in required_midi_keys:
			simple.append(MidiUtility.key_number_to_note_name_flat_up(key))
		required_midi_keys_simple = simple
		
var required_midi_keys_simple: Array[StringName] = []

var current_song: SongResource
var midi_keys_for_testing: Array[int] = [88, 86, 79, 84, 87, 86, 82, 77]
var remembered_keys: Array[StringName] = []

func produce(input_buffer: Buffer, output_buffer: Buffer) -> void:
	var keys: Array[int] = []
	var simple_names: Array[StringName] = []
	
	for i in input_locations.size():
		var note = input_buffer.consume_first_note_from_buffer(i)
		if note != null:
						
			for key in note.key_numbers:
				var simple = MidiUtility.key_number_to_note_name_flat_up(key)
				simple_names.append(simple)
				keys.append(key)
				#if !remembered_keys.has(simple):
				#	remembered_keys.append(simple)
					
			#for k in remembered_keys:
			#	print(MidiUtility.key_number_to_note_name(k))
					
			#remembered_keys = required_midi_keys
				
			#if _compare_arrays(remembered_keys, required_midi_keys):
			#	EventBus.midi_play.emit(false)
			#	MusicPlayer.play_radio_song(current_song.song_key, 3)
			#else:
			#	MusicPlayer.stop_radio_song()
			#	EventBus.midi_play.emit(true)
			#	for key in note.key_numbers:
			#		var midi_input_note = MidiInputNoteResource.new(key)
			#		EventBus.midi_input.emit(midi_input_note)
		#else:
			#MusicPlayer.stop_radio_song()
	if _is_subarray_in(required_midi_keys_simple, simple_names):
		EventBus.midi_play.emit(false)
		MusicPlayer.play_radio_song(current_song.song_key, 3)
	else:
		MusicPlayer.stop_radio_song()
		EventBus.midi_play.emit(true)
		for key in keys:
			var midi_input_note = MidiInputNoteResource.new(key)
			EventBus.midi_input.emit(midi_input_note)
	

# TODO move to some utils
## compare arrays 
func _compare_arrays(array1: Array, array2: Array) -> bool:
	if array1.size() != array2.size(): 
		return false
		
	array1.sort()
	array2.sort()
	
	for item in array1:
		if not array2.has(item):
			return false
	return true
	
func _is_subarray_in(array1: Array, array2: Array) -> bool:
	var copy = array2.duplicate()
	for item in array1:
		if not copy.has(item):
			return false
		copy.erase(item)
	return true
	

#func _to_string() -> String:
	#return "Space Radio"
#var required_midi_keys: Array[int]
#signal change_required_midi_key(midi_keys: Array[int])
