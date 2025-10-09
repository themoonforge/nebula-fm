extends AbstractBuildingResource

## takes note from input buffer, pitches and puts it into the output buffer
func produce(input_buffer: Buffer, output_buffer: Buffer) -> void:
	var note = input_buffer.consume_first_note_from_buffer()
	if note != null:
		note.key_number += 2
		pass
		#var midi_input_note = MidiInputNoteResource.new(note.key_number)
		#EventBus.midi_input.emit(midi_input_note)
