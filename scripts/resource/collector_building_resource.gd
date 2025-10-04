class_name CollectorBuildingResource extends AbstractBuildingResource

@export var note: NoteResource = null

func produce(input_buffer: Buffer, output_buffer: Buffer) -> void:
	output_buffer.add_element(note)
