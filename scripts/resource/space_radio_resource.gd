@tool
class_name SpaceRadioResource extends AbstractBuildingResource

func produce(input_buffer: Buffer, output_buffer: Buffer) -> void:
	
	for i in input_locations.size():
		var note = input_buffer.consume_first_note_from_buffer(i)
		if note != null:
			for key in note.key_numbers:
				var midi_input_note = MidiInputNoteResource.new(key)
				EventBus.midi_input.emit(midi_input_note)

#func _to_string() -> String:
	#return "Space Radio"
