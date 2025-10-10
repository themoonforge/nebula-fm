class_name BufferContentComponent extends BuildingUiComponent

@onready var input_buffer_content_container = %InputBufferContentContainer
@onready var output_buffer_content_container = %OutputBufferContentContainer
@onready var output_note_texture_rect: TextureRect = %OutputNoteTexture
@onready var input_note_texture_rect: TextureRect = %InputNoteTexture

func set_up(_building: Building) -> void:
	super._set_up(_building)
	building.note_produced.connect(_on_note_produced)

func _on_note_produced(note_package: NotePackage) -> void:
	render_note_textures(building, note_package, output_note_texture_rect)

func update() -> void:
	for i in building.building_resource.input_locations.size():
		var note_package: NotePackage = building.input_buffer.consume_first_note_from_buffer(i)
		
		if !note_package:
			continue
		
		if note_package.key_numbers.size() == 0:
			continue
			
		render_note_textures(building, note_package, input_note_texture_rect)

func render_note_textures(building: Building, note_package: NotePackage, texture_rect: TextureRect, limit: int = 1) -> void:	
	texture_rect.texture = note_package.get_texture()
