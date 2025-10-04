@tool
class_name SpaceRadioResource extends AbstractBuildingResource

func label() -> StringName:
	return "Space Radio"

func produce(input_buffer: Buffer, output_buffer: Buffer) -> void:
	var note = input_buffer.consume_first_note_from_input_buffer()
	if note != null:
		var midi_input_note = MidiInputNoteResource.new(note.key_number)
		EventBus.midi_input.emit(midi_input_note)
