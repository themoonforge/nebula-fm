@tool
class_name SpaceRadioResource extends AbstractBuildingResource

var required_midi_keys: Array[int] = []

var midi_keys_for_testing: Array[int] = [88, 86, 79, 84, 87, 86, 82, 77]


func produce(input_buffer: Buffer, output_buffer: Buffer) -> void:
	for i in input_locations.size():
		var note = input_buffer.consume_first_note_from_buffer(i)
		if note != null:
			
			# for testing
			#var midi_keys: Array[int] = [88, 86, 79, 84, 87, 86, 82, 77, 79, 82]
			#note.key_numbers = midi_keys_for_testing
			#note.key_numbers.append(79)
			#note.key_numbers.append(82)
			print(note.key_numbers)
			if _compare_arrays(note.key_numbers, required_midi_keys):
				MusicPlayer.play_radio_song("cosmic_cookies")
			else:
				MusicPlayer.stop_radio_song()
				for key in note.key_numbers:
					var midi_input_note = MidiInputNoteResource.new(key)
					EventBus.midi_input.emit(midi_input_note)
		else:
			MusicPlayer.stop_radio_song()

# TODO move to some utils
## compare arrays 
func _compare_arrays(array1: Array[int], array2: Array[int]) -> bool:
	if array1.size() != array2.size(): 
		return false
		
	array1.sort()
	array2.sort()
	
	for item in array1:
		if !array2.has(item):
			return false
	return true
	

#func _to_string() -> String:
	#return "Space Radio"
#var required_midi_keys: Array[int]
#signal change_required_midi_key(midi_keys: Array[int])
