class_name SplitterBuildingResource extends AbstractBuildingResource

func produce(input_buffer: Buffer, output_buffer: Buffer) -> void:
	#var note: NoteResource = input_buffer.consume_first_note_from_buffer()
	var note: NotePackage = input_buffer.consume_first_note_from_buffer()

	if !note:
		return

	for i in input_locations.size():
		output_buffer.add_element(note, i)

func _to_string() -> String:
	return "Splitter"
