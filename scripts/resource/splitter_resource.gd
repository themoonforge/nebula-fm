class_name SplitterBuildingResource extends AbstractBuildingResource

func produce(input_buffer: Buffer, output_buffer: Buffer) -> void:
	var note: NoteResource = input_buffer.consume_first_note_from_input_buffer()
	
	if !note:
		return
	
	output_buffer.add_element(note)
	output_buffer.add_element(note)

func label() -> StringName:
	return "Splitter"
