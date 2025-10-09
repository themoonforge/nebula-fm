@tool
class_name ConnectionManager extends Node2D

signal setup(connection_gate: ConnectionGate)
# map of own connection gates
@export var connection_gate_dict: Dictionary[Vector2i, ConnectionGate] = {} 

# map of foreigen connection gates
@export var connection_dict: Dictionary[Vector2i, ConnectionGate] = {}

func _ready() -> void:
	setup.connect(_on_setup, Object.ConnectFlags.CONNECT_DEFERRED)

func _on_setup(connection_gate: ConnectionGate) -> void:
	connection_gate_dict[connection_gate.tile_coordinate] = connection_gate
	connection_gate.area_entered.connect(func(area: Area2D): _add_connection(connection_gate.tile_coordinate, area))
	connection_gate.area_exited.connect(func(area: Area2D): _remove_connection(connection_gate.tile_coordinate, area))
	connection_gate.body_entered.connect(func(body: Node2D): _add_connection(connection_gate.tile_coordinate, body))
	connection_gate.body_exited.connect(func(body: Node2D): _remove_connection(connection_gate.tile_coordinate, body))

func clear() -> void:
	connection_gate_dict.clear()
	
func _add_connection(sourcce: Vector2i, body: Node2D) -> void:
	#print("_add_connection: ", sourcce, " ", body)
	if body is ConnectionGate:
		var connection_gate = body as ConnectionGate
		connection_dict[sourcce] = connection_gate
	
func _remove_connection(sourcce: Vector2i, body: Node2D) -> void:
	#print("_add_connection: ", sourcce, " ", body)
	connection_dict.erase(sourcce)
