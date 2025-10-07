extends Node2D

var current_tile_coord: Vector2i
var previous_tile_coord: Vector2i
var belt_dict: Dictionary[Vector2i, Node2D]

@export var bpm: float = 120.0
@export var beats_per_bar: int = 4

var time_acc: float = 0.0
var beat_time: float = 0.0
var move_t: float = 1.0

var consumed_belt: Array[Vector2i] = []

func _ready():
	belt_dict = MapManager.map_data
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
	
	if belt_dict.has(top) and previous_tile_coord != top:
		return top
	elif belt_dict.has(right) and previous_tile_coord != right:
		return right
	elif belt_dict.has(bottom) and previous_tile_coord != bottom:
		return bottom
	elif belt_dict.has(left) and previous_tile_coord != left:
		return left
		
	return Vector2i.ZERO

func _move_note():
	var top = current_tile_coord + Vector2i(0, -1)
	var right = current_tile_coord + Vector2i(1, 0)
	var bottom = current_tile_coord + Vector2i(0, 1)
	var left = current_tile_coord + Vector2i(-1, 0)
	
	if belt_dict.has(top) and previous_tile_coord != top:
		previous_tile_coord = current_tile_coord
		current_tile_coord = top
	elif belt_dict.has(right) and previous_tile_coord != right:
		previous_tile_coord = current_tile_coord
		current_tile_coord = right	
	elif belt_dict.has(bottom) and previous_tile_coord != bottom:
		previous_tile_coord = current_tile_coord
		current_tile_coord = bottom	
	elif belt_dict.has(left) and previous_tile_coord != left:
		previous_tile_coord = current_tile_coord
		current_tile_coord = left
	else:
		self.queue_free()
