class_name BuildingUi extends Control

@onready var input_buffer_content_container = %InputBufferContentContainer
@onready var output_buffer_content_container = %OutputBufferContentContainer
@onready var output_note_texture_rect: TextureRect = %OutputNoteTexture
@onready var input_note_texture_rect: TextureRect = %InputNoteTexture
@onready var panel_container: Container = %PanelContainer
@onready var building_name: Label = %BuildingNameLabel
@onready var pitch_shifter: PitchShifter = %PitchShifter

var building: Building
var is_hovered: bool

func _ready() -> void:
	panel_container.mouse_entered.connect(_on_building_ui_mouse_entered)
	panel_container.mouse_exited.connect(_on_building_ui_mouse_exited)
	pitch_shifter.pitch_shifted.connect(_on_pitch_shifted)
	
func _on_pitch_shifted(new_pitch: int) -> void:
	if building.building_resource is PitcherBuildingResource:
		building.building_resource.pitch = new_pitch
	
func _on_building_ui_mouse_entered() -> void:
	print("entered")
	is_hovered = true
	
func _on_building_ui_mouse_exited() -> void:	
	var mouse_pos = get_viewport().get_mouse_position()
	var local_mouse_pos = panel_container.get_local_mouse_position()
		
	if panel_container.get_rect().has_point(local_mouse_pos):
		is_hovered = true
		return
			
	hide()
	is_hovered = false

func setup(_building: Building) -> void:
	building = _building
	building_name.text = building.building_resource.name
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
