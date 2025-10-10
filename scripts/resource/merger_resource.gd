class_name MergerBuildingResource extends AbstractBuildingResource

@export var note_package_scene: PackedScene

func produce(input_buffer: Buffer, output_buffer: Buffer) -> void:
	var merged_key_numbers: Array[int] = []
	var new_note_package: NotePackage = null
	
	for i in input_locations.size():
		#var note: NoteResource = input_buffer.consume_first_note_from_buffer()
		var note: NotePackage = input_buffer.consume_first_note_from_buffer(i)

		if !note:
			continue
	
		if !new_note_package:
			print("hallo")
			new_note_package = note_package_scene.instantiate()
			new_note_package.current_tile_coord = note.current_tile_coord
			new_note_package.previous_tile_coord = note.previous_tile_coord
			new_note_package.belt_dict = note.belt_dict
				
		merged_key_numbers.append_array(note.key_numbers)
		note.queue_free()
	
	if merged_key_numbers.size() == 0:
		return
	
	new_note_package.key_numbers = merged_key_numbers
	output_buffer.add_element(new_note_package)

func _to_string() -> String:
	return "Merger"
