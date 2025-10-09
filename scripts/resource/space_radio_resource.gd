@tool
class_name SpaceRadioResource extends AbstractBuildingResource

func produce(input_buffer: Buffer, output_buffer: Buffer) -> void:
	var note = input_buffer.consume_first_note_from_buffer()
	if note != null:
		var midi_input_note = MidiInputNoteResource.new(note.key_number)
		EventBus.midi_input.emit(midi_input_note)

#func _to_string() -> String:
	#return "Space Radio"
