@tool
class_name DuplicateResource extends AbstractBuildingResource

func produce(input_buffer: Buffer, output_buffer: Buffer) -> void:
	var note = input_buffer.consume_first_note_from_buffer()
	if note != null:
		note.key_numbers = note.key_numbers.append_array(note.key_numbers)
		output_buffer.add_element(note)
