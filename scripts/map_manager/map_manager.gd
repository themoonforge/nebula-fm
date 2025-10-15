extends Node

signal place_obstacle(obstacle: Node2D)
signal place_building(building: Building)
signal build_mode_change(mode: Mode)
signal click_building(building: Building)
signal regenerate()

const TILE_SIZE: Vector2i = Vector2i(16, 16)
const COLOR_FREE: Color = Color(0.0, 0.894, 0.894, 0.541)
const COLOR_OCCUPIED: Color = Color(1.0, 0.68, 0.744, 0.541)
const COLOR_ADD: Color = Color(0.976, 0.827, 0.416, 0.773)

# dict with key: tiled_coord, value: object on the map
# for fast access of belts
var map_data: Dictionary[Vector2i, Building] # BELTS ONLY # TODO rename
var map_data_c_collector: Dictionary[Vector2i, Node2D] # BELTS ONLY

# just for tile map coord calculation
var ground_layer: TileMapLayer
var is_auto_conveyor_belt_tiling: bool = false
var is_hotbar_hovered: bool = false

@export var global_bpm: float = 120.0 # TODO move to conver

@export var selected_building_resource: AbstractBuildingResource = null:
	set(value):
		selected_building_resource = value
		if is_node_ready():
			building_cursor.building.building_resource = value
			
@export var building_scene: PackedScene

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
		#is_auto_conveyor_belt_tiling = false
		grid_cursor.hide()
		build_mode_change.emit(mode)
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
@onready var grid_cursor: Node2D = %GridCursor

var last_snapped_coordinate: Vector2i = Vector2i(-1, -1) # this is not a snapped coordinate!

func _ready() -> void:
	grid_cursor.hide()
	building_cursor.hide()
	building_cursor.building.building_resource = selected_building_resource
	
	ground_layer = load("res://scenes/map/ground_layer_ref.tscn").instantiate()
	
	EventBus.hotbar_hovered.connect(	_on_hotbar_hovered)

func _process(delta: float) -> void:
	if !building_cursor:
		return

	var mouse_pos = get_viewport().get_mouse_position()
	var canvas_transform = get_viewport().get_canvas_transform()
	var world_mouse_pos = canvas_transform.affine_inverse() * mouse_pos

	building_cursor.global_position = world_mouse_pos

	var hovered_cell: Vector2i = Vector2i(world_mouse_pos.x / 16, world_mouse_pos.y / 16)
	var snapped_coordinate: Vector2i = (world_mouse_pos - Vector2(TILE_SIZE.x / 2, TILE_SIZE.y / 2)).snapped(TILE_SIZE)
	snapped_coordinate = snapped_coordinate - Vector2i(0, -16)

	if mode == Mode.DELETE && Input.is_action_just_pressed(&"delete"):
		mode = Mode.IDLE
		return

	if mode != Mode.DELETE && Input.is_action_just_pressed(&"delete"):
		mode = Mode.DELETE
		return

	match mode:
		Mode.BUILD:
			if Input.is_action_just_pressed(&"rotate_right") and !is_auto_conveyor_belt_tiling:
				building_cursor.building.building_rotation = BuildingsUtils.rightRotation(building_cursor.building.building_rotation)
				MusicPlayer.play_sfx("ui_click_tsk")

			if Input.is_action_just_pressed(&"rotate_left") and !is_auto_conveyor_belt_tiling:
				building_cursor.building.building_rotation = BuildingsUtils.leftRotation(building_cursor.building.building_rotation)
				MusicPlayer.play_sfx("ui_click_tsk")

			building_cursor.global_position = snapped_coordinate
			grid_cursor.show()
			grid_cursor.global_position = snapped_coordinate

			if building_cursor.collider_dict.size() > 0 or !GridManager.is_cell_free(hovered_cell):
				var is_crater: bool = false
				
				if building_cursor.building.building_resource is ConveyorResource:
					for b in building_cursor.collider_dict:
						if b.name == "CraterLayer":
							is_crater = true
				
				if !is_crater:
					grid_cursor.hide()
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
				
			if is_hotbar_hovered:
				building_cursor.building.modulate_sprite(COLOR_OCCUPIED)
				return
			else:
				building_cursor.building.modulate_sprite(COLOR_FREE)
				
			if Input.is_action_just_pressed(&"ui_click"):
				grid_cursor.hide()
				
				var building: Building = building_scene.instantiate()
				building.building_resource = building_cursor.building.building_resource
				building.global_position = building_cursor.global_position
				building.building_rotation = building_cursor.building.building_rotation
				building.is_active = true
				var tile_coordinate = ground_layer.local_to_map(building_cursor.global_position)
				
				building.tile_coord = tile_coordinate
				if building.building_resource.building_key.begins_with("conveyor_belt"): # TODO maybe improve this
					if is_auto_conveyor_belt_tiling:
						_evaluate_conveyor_belt_direction(tile_coordinate, building)
					map_data[tile_coordinate] = building
					
				elif building.building_resource.building_key == StringName("collector"):
					map_data_c_collector[tile_coordinate] = building
				
				building.name = building.building_resource.name + "_" + str(Time.get_unix_time_from_system())
				
				place_obstacle.emit(building)
				print("placed building")
				place_building.emit(building)
				MusicPlayer.play_sfx("build_placed")
				
				building.set_up_shape_polygon(building.tile_coord)

				if GridManager.is_cell_free(hovered_cell):
					GridManager.set_cell(hovered_cell)
				if !Input.is_action_pressed(&"build_continue"):
					mode = Mode.IDLE
		Mode.DELETE:
			delete_cursor.global_position = snapped_coordinate
			
			for building in delete_cursor.collider_dict:
				if building.building_resource is SpaceRadioResource:
					delete_cursor.is_active = false
					return
			
			delete_cursor.is_active = true
			
			if Input.is_action_just_pressed(&"ui_click"):
				for building in delete_cursor.collider_dict:
					if building.building_resource is SpaceRadioResource:
						continue
						 
					#print("free: ", building.is_active)
					if building.building_resource.name == StringName("Conveyor Belt") or StringName("corner_b") or StringName("corner_f"):
						map_data.erase(building.tile_coord)
						
					if building.building_resource.name == &"C-Collector":
						map_data_c_collector.erase(building.tile_coord)
						
					building.queue_free()
					if !GridManager.is_cell_free(hovered_cell):
						GridManager.free_cell(hovered_cell)
					
		Mode.IDLE:
			return
			
func _on_hotbar_hovered(hovered: bool) -> void:
	is_hotbar_hovered = hovered

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
	
	is_auto_conveyor_belt_tiling = transformer_resource.building_key == "conveyor_belt_auto"
	if is_auto_conveyor_belt_tiling:
		building_cursor.building.building_rotation = BuildingsUtils.BuildingRotation.DOWN
	

# checks if building (or belt) has neighbour belts
func has_neighbours(root_position):
	var top = root_position + Vector2i(0, -1)
	var right = root_position + Vector2i(1, 0)
	var bottom = root_position + Vector2i(0, 1)
	var left = root_position + Vector2i(-1, 0)
			
	return map_data.has(top) or map_data.has(right) or map_data.has(bottom) or map_data.has(left)

func count_neighbours(root_position):
	var top = root_position + Vector2i(0, -1)
	var right = root_position + Vector2i(1, 0)
	var bottom = root_position + Vector2i(0, 1)
	var left = root_position + Vector2i(-1, 0)
	
	#Debug.debug_print("root_position: ", root_position)
	#Debug.debug_print("count_neighbours")
	#Debug.debug_print("top: ", top)
	#Debug.debug_print("right: ", right)
	#Debug.debug_print("bottom: ", bottom)
	#Debug.debug_print("left: ", left)
	
	var count_of_neighbours = 0
	if map_data.has(top):
		count_of_neighbours += 1
	if map_data.has(right):
		count_of_neighbours += 1	
	if map_data.has(bottom):
		count_of_neighbours += 1
	if map_data.has(left):
		count_of_neighbours += 1
	
	#Debug.debug_print("count neighbours", count_of_neighbours)
	return count_of_neighbours
	
# TODO compare with implementation of note movement flow (in note.tscn) and align implementations (they do similar things in different ways)
# the conveyor belt autotiling implementation (rotates the placed tile based on the present tile)
func _evaluate_conveyor_belt_direction(root_position: Vector2i, building: Building):
	
	# check 4 directions
	var top = root_position + Vector2i(0, -1)
	var right = root_position + Vector2i(1, 0)
	var bottom = root_position + Vector2i(0, 1)
	var left = root_position + Vector2i(-1, 0)
		
	# local variable for data of the map. data is a building
	var data: Building
	if map_data.has(top):
		data = map_data.get(top)
		
		#check if the belt to connect with already has connections
		if data is Building and count_neighbours(top) <= 1:
			# check rotation
			building.building_rotation = BuildingsUtils.BuildingRotation.DOWN
	
	elif map_data.has(right):
		data = map_data.get(right)
		
		#check if the belt to connect with already has connections		
		if data is Building and count_neighbours(right) <= 1:
			# check rotation
			building.building_rotation = BuildingsUtils.BuildingRotation.LEFT
			
	elif map_data.has(left):
		data = map_data.get(left)
		
		#check if the belt to connect with already has connections
		if data is Building and count_neighbours(left) <= 1:
			# check rotation
			building.building_rotation = BuildingsUtils.BuildingRotation.RIGHT

	elif map_data.has(bottom):
		data = map_data.get(bottom)
		
		#check if the belt to connect with already has connections
		if data is Building and count_neighbours(bottom) <= 1:
			building.building_rotation = BuildingsUtils.BuildingRotation.UP
				
	else:
		return
	
	var tile_coordinate = ground_layer.local_to_map(data.global_position)
	data.tile_coord = tile_coordinate
	
	_find_corner(data, building)
		
# checks if the new_belt "creates" a corner and replaces the present or the new belt (depending on the case) with the matching corner tile
func _find_corner(present_belt: Building, new_belt: Building):
	
	# HOW the two buildings are located to each other 
	var a = present_belt.tile_coord
	var b = new_belt.tile_coord
	
	var is_a_right_of_b = a.x > b.x
	var is_a_left_of_b = a.x < b.x
	var is_a_above_b = a.y < b.y
	var is_a_below_b = a.y > b.y
	
	# LOCATION STATES (THESE ARE THE ROTATIONS!)
	var a_is_right = present_belt.building_rotation == BuildingsUtils.BuildingRotation.RIGHT
	var a_is_left = present_belt.building_rotation == BuildingsUtils.BuildingRotation.LEFT
	var a_is_up = present_belt.building_rotation == BuildingsUtils.BuildingRotation.UP
	var a_is_down = present_belt.building_rotation == BuildingsUtils.BuildingRotation.DOWN
	
	var b_is_right = new_belt.building_rotation == BuildingsUtils.BuildingRotation.RIGHT
	var b_is_left = new_belt.building_rotation == BuildingsUtils.BuildingRotation.LEFT
	var b_is_up = new_belt.building_rotation == BuildingsUtils.BuildingRotation.UP
	var b_is_down = new_belt.building_rotation == BuildingsUtils.BuildingRotation.DOWN
	
	# CORNER STATES
	var is_top_right_corner_f = (is_a_above_b and a_is_right and b_is_down) or (is_a_below_b and a_is_down and b_is_right)
	var is_bottom_right_corner_f = (is_a_right_of_b and a_is_down and b_is_left) or (is_a_left_of_b and a_is_left and b_is_down)
	var is_bottom_left_f = (is_a_above_b and a_is_up and b_is_left) or (is_a_below_b and a_is_left and b_is_up)
	var is_top_left_f = (is_a_right_of_b and a_is_right and b_is_up) or (is_a_left_of_b and a_is_up and b_is_right)

	var is_top_right_corner_b = (is_a_right_of_b and a_is_up and b_is_left) or (is_a_left_of_b and a_is_left and b_is_up)
	var is_botton_right_corner_b = (is_a_above_b and a_is_up and b_is_right) or (is_a_below_b and a_is_right and b_is_up)
	var is_bottom_left_b = (is_a_right_of_b and a_is_right and b_is_down) or (is_a_left_of_b and a_is_down and b_is_right)
	var is_top_left_b = (is_a_above_b and a_is_left and b_is_down) or (is_a_below_b and a_is_down and b_is_left)
	
	# changes the resource of the belt: conveyor belt -> conveyo belt corner <flow direction>
	var belt_to_replace: Building
	
	var conveyor_belt_corner_f = load("res://resources/building/conveyor_belt_corner_f.tres")
	var conveyor_belt_corner_b = load("res://resources/building/conveyor_belt_corner_b.tres")

	# FORWARD DIRECTION

	if is_top_right_corner_f:
		Debug.debug_print("is_top_right_corner_f")
		
		# retrieve the building to replace the resource of
		if is_a_above_b:
			Debug.debug_print("is_a_above_b")
			belt_to_replace = present_belt
		elif is_a_below_b:
			Debug.debug_print("is_a_below_b")
			belt_to_replace = new_belt
				
		belt_to_replace.building_resource = conveyor_belt_corner_f
		belt_to_replace.building_rotation = BuildingsUtils.BuildingRotation.DOWN
	
	elif is_bottom_right_corner_f:
		Debug.debug_print("is_bottom_right_corner_f")
		
		# retrieve the building to replace the resource of
		if is_a_right_of_b:
			Debug.debug_print("is_a_right_of_b")
			belt_to_replace = present_belt
		elif is_a_left_of_b:
			Debug.debug_print("is_a_left_of_b")
			belt_to_replace = new_belt
				
		belt_to_replace.building_resource = conveyor_belt_corner_f
		belt_to_replace.building_rotation = BuildingsUtils.BuildingRotation.LEFT	

	elif is_bottom_left_f:
		Debug.debug_print("is_bottom_left_f")
		# retrieve the building to replace the resource of
		if is_a_below_b:
			Debug.debug_print("is_a_below_b")
			belt_to_replace = present_belt
		elif is_a_above_b:
			Debug.debug_print("is_a_above_b")
			belt_to_replace = new_belt
				
		belt_to_replace.building_resource = conveyor_belt_corner_f
		belt_to_replace.building_rotation = BuildingsUtils.BuildingRotation.UP	
		
	elif is_top_left_f:
		Debug.debug_print("is_top_left_f")
		# retrieve the building to replace the resource of
		if is_a_left_of_b:
			Debug.debug_print("is_a_left_of_b")
			belt_to_replace = present_belt
		elif is_a_right_of_b:
			Debug.debug_print("is_a_right_of_b")
			belt_to_replace = new_belt
				
		belt_to_replace.building_resource = conveyor_belt_corner_f
		belt_to_replace.building_rotation = BuildingsUtils.BuildingRotation.RIGHT	
		
	# BACKWARD DIRECTION
	
	elif is_top_right_corner_b:
		Debug.debug_print("is_top_right_corner_b")
		# retrieve the building to replace the resource of
		if is_a_right_of_b:
			Debug.debug_print("is_a_right_of_b")
			belt_to_replace = present_belt
		elif is_a_left_of_b:
			Debug.debug_print("is_a_left_of_b")
			belt_to_replace = new_belt	
			
		belt_to_replace.building_resource = conveyor_belt_corner_b
		belt_to_replace.building_rotation = BuildingsUtils.BuildingRotation.DOWN	

	elif is_botton_right_corner_b:
		Debug.debug_print("is_botton_right_corner_b")
		# retrieve the building to replace the resource of
		if is_a_below_b:
			Debug.debug_print("is_a_below_b")
			belt_to_replace = present_belt
		elif is_a_above_b:
			Debug.debug_print("is_a_above_b")
			belt_to_replace = new_belt	
			
		belt_to_replace.building_resource = conveyor_belt_corner_b
		belt_to_replace.building_rotation = BuildingsUtils.BuildingRotation.RIGHT	
		
	elif is_bottom_left_b:
		Debug.debug_print("is_bottom_left_b")
		# retrieve the building to replace the resource of
		if is_a_left_of_b:
			Debug.debug_print("is_a_left_of_b")
			belt_to_replace = present_belt
		elif is_a_right_of_b:
			Debug.debug_print("is_a_right_of_b")
			belt_to_replace = new_belt	
			
		belt_to_replace.building_resource = conveyor_belt_corner_b
		belt_to_replace.building_rotation = BuildingsUtils.BuildingRotation.UP
		
	elif is_top_left_b:
		Debug.debug_print("is_top_left_b")
		# retrieve the building to replace the resource of
		if is_a_above_b:
			Debug.debug_print("is_a_above_b")
			belt_to_replace = present_belt
		elif is_a_below_b:
			Debug.debug_print("is_a_below_b")
			belt_to_replace = new_belt	
			
		belt_to_replace.building_resource = conveyor_belt_corner_b
		belt_to_replace.building_rotation = BuildingsUtils.BuildingRotation.LEFT
		
# autotiles cornes of conveyor belts
func _find_corners(root_position: Vector2i, building: Building):
	
	var top = root_position + Vector2i(0, -1)
	var right = root_position + Vector2i(1, 0)
	var bottom = root_position + Vector2i(0, 1)
	var left = root_position + Vector2i(-1, 0)

	if map_data.has(top):
		var data = map_data.get(top)
		
		if data is Building:	
			# check rotation
			building.building_rotation = BuildingsUtils.BuildingRotation.DOWN
	
	elif map_data.has(right):
		var data = map_data.get(right)
		
		if data is Building:
			# check rotation
			building.building_rotation = BuildingsUtils.BuildingRotation.LEFT
			
	elif map_data.has(left):
		var data = map_data.get(left)
		
		if data is Building:
			# check rotation
			building.building_rotation = BuildingsUtils.BuildingRotation.RIGHT

	elif map_data.has(bottom):
		var data = map_data.get(bottom)
		
		if data is Building:
			# check rotation
			building.building_rotation = BuildingsUtils.BuildingRotation.UP
