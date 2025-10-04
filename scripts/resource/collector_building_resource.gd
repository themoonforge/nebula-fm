@tool
class_name CollectorBuildingResource extends AbstractBuildingResource

@export var note: NoteResource = null:
	set(value):
		note = value

func produce(input_buffer: Buffer, output_buffer: Buffer) -> void:
	output_buffer.add_element(note)

func label() -> StringName:
	if note == null:
		return ""
	return note.simple_name
