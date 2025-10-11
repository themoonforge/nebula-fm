extends Node2D

class_name NotePackage

@export var current_tile_coord: Vector2i = Vector2i(INF, INF)
@export var previous_tile_coord: Vector2i = Vector2i(INF, INF)
@export var next_tile_coord: Vector2i = Vector2i(INF, INF)
#var belt_dict: Dictionary[Vector2i, Building]

@export var bpm: float = 120.0
@export var beats_per_bar: int = 4
@export var c_texture: Texture
@export var d_texture: Texture
@export var e_texture: Texture
@export var f_texture: Texture
@export var g_texture: Texture
@export var a_texture: Texture
@export var b_texture: Texture
@export var package_texture: Texture

var time_acc: float = 0.0
var beat_time: float = 0.0
var move_t: float = 1.0
		
@export var key_numbers: Array[int]

func _ready():
	beat_time = 60.0 / bpm
	
	if MapManager.ground_layer:
		position = MapManager.ground_layer.map_to_local(current_tile_coord)
		next_tile_coord = current_tile_coord
		previous_tile_coord = Vector2i(INF, INF)

func _process(delta: float) -> void:
	time_acc += delta
	if time_acc >= beat_time:
		time_acc = 0.0
		_move_note()
	
	var t = time_acc / beat_time
	_lerp_move_note(t)

func _lerp_move_note(t: float) -> void:
	if next_tile_coord == Vector2i.ZERO:
		return
	
	var start_position = MapManager.ground_layer.map_to_local(current_tile_coord)
	var target_position = MapManager.ground_layer.map_to_local(next_tile_coord)
	position = start_position.lerp(target_position, t)

func _move_note():
	# step to next -> previous movement finished
	current_tile_coord = next_tile_coord
	
	var top = current_tile_coord + Vector2i.UP
	var right = current_tile_coord + Vector2i.RIGHT
	var bottom = current_tile_coord + Vector2i.DOWN
	var left = current_tile_coord + Vector2i.LEFT
	
	var possible_belts: Array[Building] = []

	if MapManager.map_data.has(top):
		possible_belts.append(MapManager.map_data.get(top))
	if MapManager.map_data.has(right):
		possible_belts.append(MapManager.map_data.get(right))
	if MapManager.map_data.has(bottom):
		possible_belts.append(MapManager.map_data.get(bottom))
	if MapManager.map_data.has(left):
		possible_belts.append(MapManager.map_data.get(left))
	
	for next_belt in possible_belts:
		if !MapManager.map_data.has(current_tile_coord) or previous_tile_coord == next_belt.tile_coord:
			continue
		
		var curr_belt: Building = MapManager.map_data.get(current_tile_coord)
		var allowed_movement_vector: Vector2i = Vector2i.ZERO
		
		match curr_belt.building_resource.building_key:
			&"conveyor_belt_auto", &"conveyor_belt_manual":
				match curr_belt.building_rotation:
					BuildingsUtils.BuildingRotation.DOWN:
						allowed_movement_vector = Vector2i.DOWN
					BuildingsUtils.BuildingRotation.RIGHT:
						allowed_movement_vector = Vector2i.RIGHT
					BuildingsUtils.BuildingRotation.UP:
						allowed_movement_vector = Vector2i.UP
					BuildingsUtils.BuildingRotation.LEFT:
						allowed_movement_vector = Vector2i.LEFT
			&"conveyor_belt_corner_f":
				match curr_belt.building_rotation:
					BuildingsUtils.BuildingRotation.DOWN:
						allowed_movement_vector = Vector2i.DOWN
					BuildingsUtils.BuildingRotation.RIGHT:
						allowed_movement_vector = Vector2i.RIGHT
					BuildingsUtils.BuildingRotation.UP:
						allowed_movement_vector = Vector2i.UP
					BuildingsUtils.BuildingRotation.LEFT:
						allowed_movement_vector = Vector2i.LEFT
			&"conveyor_belt_corner_b":
				match curr_belt.building_rotation:
					BuildingsUtils.BuildingRotation.DOWN:
						allowed_movement_vector = Vector2i.LEFT
					BuildingsUtils.BuildingRotation.RIGHT:
						allowed_movement_vector = Vector2i.UP
					BuildingsUtils.BuildingRotation.UP:
						allowed_movement_vector = Vector2i.RIGHT
					BuildingsUtils.BuildingRotation.LEFT:
						allowed_movement_vector = Vector2i.DOWN
			
		var curr_belt_key: StringName = curr_belt.building_resource.building_key
		var next_belt_key: StringName = next_belt.building_resource.building_key
		
		# HELPERS (for better readability)		
		var curr_is_straight = curr_belt_key == &"conveyor_belt_auto" or curr_belt_key == &"conveyor_belt_manual"
		var curr_is_corner_f = curr_belt_key == &"conveyor_belt_corner_f"
		var curr_is_corner_b = curr_belt_key == &"conveyor_belt_corner_b"

		var next_is_straight = next_belt_key == &"conveyor_belt_auto" or next_belt_key == &"conveyor_belt_manual"
		var next_is_corner_f = next_belt_key == &"conveyor_belt_corner_f"
		var next_is_corner_b = next_belt_key == &"conveyor_belt_corner_b"
		
		var curr_rotation: BuildingsUtils.BuildingRotation = curr_belt.building_rotation
		var next_rotation: BuildingsUtils.BuildingRotation = next_belt.building_rotation
		
		var has_same_rotation = next_belt.building_rotation == curr_belt.building_rotation
				
		# FLOW CASES: 
		var is_case_a = curr_is_straight and next_is_straight and has_same_rotation
		
		# check if the straight belts are rotated correctly based ont the position (e.g. to avoid curr_down, next_down next to each other)
		var is_case_a_2 = curr_rotation in [0, 2] and curr_belt.tile_coord.y != next_belt.tile_coord.y and curr_belt.tile_coord.x == next_belt.tile_coord.x
		var is_case_a_3 = curr_rotation in [1, 3] and curr_belt.tile_coord.x != next_belt.tile_coord.x and curr_belt.tile_coord.y == next_belt.tile_coord.y
		is_case_a = is_case_a and (is_case_a_2 or is_case_a_3)
		
		var is_case_b = curr_is_straight and next_is_corner_f and next_rotation == (curr_rotation + 3) % 4
		var is_case_c = curr_is_straight and next_is_corner_b and next_rotation == abs((curr_rotation - 2) % 4)
		
		var is_case_d = curr_is_corner_f and next_is_straight and has_same_rotation
		var is_case_e = curr_is_corner_f and next_is_corner_f and next_rotation == (curr_rotation + 3) % 4
		var is_case_f = curr_is_corner_f and next_is_corner_b and next_rotation == abs((curr_rotation - 2) % 4)
		
		var is_case_g = curr_is_corner_b and next_is_straight and next_rotation == abs((curr_rotation - 3) % 4)
		var is_case_h = curr_is_corner_b and next_is_corner_f and next_rotation == abs((curr_rotation - 2) % 4)
		var is_case_i = curr_is_corner_b and next_is_corner_b and next_rotation == (curr_rotation + 3) % 4
		
		if is_case_a or is_case_b or is_case_c or is_case_d or is_case_e or is_case_f or is_case_g or is_case_h or is_case_i:
			var real_movement_vector1 = next_belt.tile_coord - current_tile_coord
			var real_movement_vector2 = next_belt.tile_coord - curr_belt.tile_coord
			
			if previous_tile_coord != Vector2i(INF, INF) and (real_movement_vector1 != allowed_movement_vector or real_movement_vector2 != allowed_movement_vector):
				continue
			
			previous_tile_coord = current_tile_coord
			next_tile_coord = next_belt.tile_coord
			
			return
	
	self.queue_free()
		
func get_texture() -> Texture:
	if key_numbers.size() == 1:
		match(key_numbers[0] % 12):
			0, 1:
				return c_texture
			2, 3:
				return d_texture
			4:
				return e_texture
			5, 6:
				return f_texture
			7, 8:
				return g_texture
			9, 10:
				return a_texture
			11:
				return b_texture
	else:
		return package_texture
		
	return null
