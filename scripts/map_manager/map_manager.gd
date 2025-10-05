extends Node

signal place_obstacle(obstacle: Node2D)

const TILE_SIZE: Vector2i = Vector2i(16, 16)
const COLOR_FREE: Color = Color(0.0, 0.894, 0.894, 0.541)
const COLOR_OCCUPIED: Color = Color(1.0, 0.68, 0.744, 0.541)
const COLOR_ADD: Color = Color(0.976, 0.827, 0.416, 0.773)

@export var selected_building_resource: AbstractBuildingResource = null:
	set(value):
		selected_building_resource = value
		if is_node_ready():
			building_cursor.building.building_resource = value

enum Mode {
	BUILD, DELETE, IDLE
}

var transformer_ghost_instance: TransformerGhost
var transformer_ghost_active: bool
var placed_transformers: Dictionary[Vector2i, Transformer]
var note_sources: Array[Vector2i]

@export var mode: Mode = Mode.IDLE:
	set(value):
		mode = value
		match mode:
			Mode.BUILD:
				building_cursor.show()
				delete_cursor.hide()
				delete_cursor.is_active = false
			Mode.DELETE:
				building_cursor.hide()
				delete_cursor.show()
				delete_cursor.is_active = true
			Mode.IDLE:
				building_cursor.hide()
				delete_cursor.hide()
				delete_cursor.is_active = false

@onready var building_cursor: BuildingCursor = %BuildingCursor
@onready var delete_cursor: DeleteCursor = %DeleteCursor

var last_snapped_coordinate: Vector2i = Vector2i(-1, -1) # this is not a snapped coordinate!

func _ready() -> void:
	building_cursor.hide()
	add_child(building_cursor)

	building_cursor.building.building_resource = selected_building_resource

func _process(delta: float) -> void:
	if !building_cursor:
		return

	var mouse_pos = get_viewport().get_mouse_position()
	building_cursor.global_position = mouse_pos

	var hovered_cell: Vector2i = Vector2i(mouse_pos.x / 16, mouse_pos.y / 16)
	var snapped_coordinate: Vector2i = (mouse_pos - Vector2(TILE_SIZE.x / 2, TILE_SIZE.y / 2)).snapped(TILE_SIZE)
	snapped_coordinate = snapped_coordinate - Vector2i(0, -16)

	if Input.is_action_just_pressed(&"escape"):
		mode = Mode.IDLE
		return

	if Input.is_action_just_pressed(&"delete"):
		mode = Mode.DELETE
		return

	match mode:
		Mode.BUILD:
			if Input.is_action_just_pressed(&"rotate_right"):
				building_cursor.building.building_rotation = BuildingsUtils.rightRotation(building_cursor.building.building_rotation)

			if Input.is_action_just_pressed(&"rotate_left"):
				building_cursor.building.building_rotation = BuildingsUtils.leftRotation(building_cursor.building.building_rotation)

			building_cursor.global_position = snapped_coordinate

			if building_cursor.collider_dict.size() > 0:
				building_cursor.building.modulate_sprite(COLOR_OCCUPIED)
				return
					
			if building_cursor.building.building_resource is CollectorBuildingResource:
				if _borders_note_source(hovered_cell):
					building_cursor.building.modulate_sprite(COLOR_ADD)
				else:
					building_cursor.building.modulate_sprite(COLOR_OCCUPIED)
					return
			else:
				building_cursor.building.modulate_sprite(COLOR_FREE)

			if Input.is_action_just_pressed(&"ui_click"):
				#var clicked_position: Vector2 = mouse_pos
				#var clicked_cell: Vector2i = Vector2i(mouse_pos.x / 16, mouse_pos.y / 16)
				var building = building_cursor.building.duplicate()
				building.global_position = building_cursor.global_position
				building.is_active = true
				place_obstacle.emit(building)

				#if GridManager.is_cell_free(clicked_cell):
				#	GridManager.set_cell(clicked_cell)
				if !Input.is_action_pressed(&"build_continue"):
					mode = Mode.IDLE
		Mode.DELETE:
			delete_cursor.global_position = snapped_coordinate
			if Input.is_action_just_pressed(&"ui_click"):
				for building in delete_cursor.collider_dict:
					#print("free: ", building.is_active)
					building.queue_free()
		Mode.IDLE:
			pass
			
func _borders_note_source(cell: Vector2i) -> bool:
	for note_cell in note_sources:
		if note_cell == cell + Vector2i(0, -1):
			return true
		if note_cell == cell + Vector2i(0, 1):
			return true
		if note_cell == cell + Vector2i(-1, 0):
			return true
		if note_cell == cell + Vector2i(1, 0):
			return true
	return false

func add_note_source(cell: Vector2i):
	if note_sources.has(cell):
		return
		
	note_sources.append(cell)

func free_buildings() -> void:
	var buildings = get_tree().get_nodes_in_group(BuildingsUtils.BUILDING_GROUP)
	for building in buildings:
		building.queue_free()

func hide_ghost() -> void:
	mode = Mode.IDLE

func set_active_transformer_ghost(transformer_resource: AbstractBuildingResource) -> void:
	if !building_cursor:
		return
	
	building_cursor.building.building_resource = transformer_resource
	building_cursor.building.modulate_sprite(COLOR_FREE)
	building_cursor.building.show_connection_indicators = true
	mode = Mode.BUILD
