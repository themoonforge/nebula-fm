extends Node2D

var current_tile_coord:
	set(value):
		current_tile_coord = value
		if MapManager.ground_layer:
			var local_position = MapManager.ground_layer.map_to_local(value)
			self.position = local_position
			
var previous_tile_coord
#var next_tile_coord

@export var bpm: float = 120.0
@export var beats_per_bar: int = 4

var time_acc: float = 0.0
var beat_time: float = 0.0

var move_t: float = 1.0

func _ready():
	beat_time = 60.0 / bpm

func _process(delta: float) -> void:
	time_acc += delta
	if time_acc >= beat_time:
		time_acc = 0.0
		_move_note()
		
var consumed_belt: Array[Vector2i] = []

func _move_note():
	var belt_dict = MapManager.map_data as Dictionary[Vector2i, Node2D] # (TODO original rename member)

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
