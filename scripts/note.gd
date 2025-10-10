extends Node2D

class_name NotePackage

var current_tile_coord: Vector2i
var previous_tile_coord: Vector2i
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

#var consumed_belt: Array[Vector2i] = [] # TODO remove

## key_number refers to the midi key map 
## https://djip.co/blog/logic-studio-9-midi-note-numbers
#@export var key_number: int = 0:
	#set(value):
		#key_number = value
		#name = MidiUtility.key_number_to_note_name_with_octave(key_number)
		##resource_name = name
		#simple_name = MidiUtility.key_number_to_note_name(key_number)
		
@export var key_numbers: Array[int]

#func _init(key_number: int = 0) -> void:
	#self.key_number = key_number

func _ready():
	#belt_dict = MapManager.map_data
	beat_time = 60.0 / bpm
	
	if MapManager.ground_layer:
		position = MapManager.ground_layer.map_to_local(current_tile_coord)

func _process(delta: float) -> void:
	time_acc += delta
	if time_acc >= beat_time:
		time_acc = 0.0
		_move_note()
	
	var t = time_acc / beat_time
	_lerp_move_note(t)

func _lerp_move_note(t: float) -> void:
	var _next_tile_coord = _get_next_tile_coord()
	if _next_tile_coord == Vector2i.ZERO:
		return
	
	var start_position = MapManager.ground_layer.map_to_local(current_tile_coord)
	var target_position = MapManager.ground_layer.map_to_local(_next_tile_coord)
	position = start_position.lerp(target_position, t)
	
func _get_next_tile_coord() -> Vector2i:
	var top = current_tile_coord + Vector2i(0, -1)
	var right = current_tile_coord + Vector2i(1, 0)
	var bottom = current_tile_coord + Vector2i(0, 1)
	var left = current_tile_coord + Vector2i(-1, 0)
	
	if MapManager.map_data.has(top) and previous_tile_coord != top:
		return top
	elif MapManager.map_data.has(right) and previous_tile_coord != right:
		return right
	elif MapManager.map_data.has(bottom) and previous_tile_coord != bottom:
		return bottom
	elif MapManager.map_data.has(left) and previous_tile_coord != left:
		return left
		
	return Vector2i.ZERO

func _move_note():
	var top = current_tile_coord + Vector2i(0, -1)
	var right = current_tile_coord + Vector2i(1, 0)
	var bottom = current_tile_coord + Vector2i(0, 1)
	var left = current_tile_coord + Vector2i(-1, 0)
	
	var possible_belts: Array[Building] = []
	
	#var top_belt: Building = MapManager.map_data.get(top)
	#var right_belt: Building = MapManager.map_data.get(right)
	#var bottom_belt: Building = MapManager.map_data.get(bottom)
	#var left_belt: Building = MapManager.map_data.get(left)

	if MapManager.map_data.has(top):
		possible_belts.append(MapManager.map_data.get(top))
	if MapManager.map_data.has(right):
		possible_belts.append(MapManager.map_data.get(right))
	if MapManager.map_data.has(bottom):
		possible_belts.append(MapManager.map_data.get(bottom))		
	if MapManager.map_data.has(left):
		possible_belts.append(MapManager.map_data.get(left))		
	
	for next_belt in possible_belts:
		if !MapManager.map_data.has(current_tile_coord):
			continue
			
		var curr_belt: Building = MapManager.map_data.get(current_tile_coord)	
		var curr_belt_key: StringName = curr_belt.building_resource.building_key
		var next_belt_key: StringName = next_belt.building_resource.building_key
		
		# HELPERS (for better readability)		
		var curr_is_straight = curr_belt_key == &"conveyor_belt_auto" or curr_belt_key == &"conveyor_belt_manual"
		var curr_is_corner_f = curr_belt_key == &"conveyor_belt_corner_f"
		var curr_is_corner_b = curr_belt_key == &"conveyor_belt_corner_b"

		var next_is_straight = next_belt_key == &"conveyor_belt_auto" or next_belt_key == &"conveyor_belt_manual"
		var next_is_corner_f = next_belt_key == &"conveyor_belt_corner_f"
		var next_is_corner_b = next_belt_key == &"conveyor_belt_corner_b"
		
		var curr_rotation = curr_belt.building_rotation
		var next_rotation = next_belt.building_rotation
		
		var has_same_rotation = next_belt.building_rotation == curr_belt.building_rotation
				
		# FLOW CASES: 
		var is_case_a = curr_is_straight and next_is_straight and has_same_rotation
		var is_case_b = curr_is_straight and next_is_corner_f and next_rotation == (curr_rotation + 3) % 4
		var is_case_c = curr_is_straight and next_is_corner_b and next_rotation == (curr_rotation - 2) % 4
		
		var is_case_d = curr_is_corner_f and next_is_straight and has_same_rotation
		var is_case_e = curr_is_corner_f and next_is_corner_f and next_rotation == (curr_rotation + 3) % 4
		var is_case_f = curr_is_corner_f and next_is_corner_b and next_rotation == (curr_rotation - 2) % 4
		
		var is_case_g = curr_is_corner_b and next_is_straight and next_rotation == (curr_rotation - 3) % 4
		var is_case_h = curr_is_corner_b and next_is_corner_f and next_rotation == (curr_rotation - 2) % 4
		var is_case_i = curr_is_corner_b and next_is_corner_b and next_rotation == (curr_rotation + 3) % 4
		
		if is_case_a or is_case_b or is_case_c or is_case_d or is_case_e or is_case_f or is_case_g or is_case_h or is_case_i:
			previous_tile_coord = current_tile_coord
			current_tile_coord = next_belt.tile_coord
			return
	
	self.queue_free()

	
	#if belt_dict.has(top) and previous_tile_coord != top:
		#previous_tile_coord = current_tile_coord
		#current_tile_coord = top
	#elif belt_dict.has(right) and previous_tile_coord != right:
		#previous_tile_coord = current_tile_coord
		#current_tile_coord = right
	#elif belt_dict.has(bottom) and previous_tile_coord != bottom:
		#previous_tile_coord = current_tile_coord
		#current_tile_coord = bottom	
	#elif belt_dict.has(left) and previous_tile_coord != left:
		#previous_tile_coord = current_tile_coord
		#current_tile_coord = left
	#else:
		#self.queue_free()
		
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
