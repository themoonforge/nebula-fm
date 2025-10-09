class_name PitcherBuildingResource extends AbstractBuildingResource

## takes note from input buffer, pitches and puts it into the output buffer
func produce(input_buffer: Buffer, output_buffer: Buffer) -> void:
	var note = input_buffer.consume_first_note_from_buffer()
	if note != null:
		var pitched_keys: Array[int] = []
		for key in note.key_numbers:
			key += 2
			pitched_keys.append(key)
			
		note.key_numbers = pitched_keys
		output_buffer.add_element(note)

		#var midi_input_note = MidiInputNoteResource.new(note.key_number)
		#EventBus.midi_input.emit(midi_input_note)
