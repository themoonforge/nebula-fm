@tool
class_name ConnectionGate extends Area2D

@onready var shape: CollisionShape2D = %CollisionShape2D
@export var mode: Building.ConnectionType:
	set(value):
		mode = value
		match mode:
			Building.ConnectionType.INPUT:
				collision_layer = 4 # input layer
				collision_mask = 8 # output layer
			Building.ConnectionType.OUTPUT:
				collision_layer = 8 # output layer
				collision_mask = 4 # input layer

@export var is_active: bool = false:
	set(value):
		is_active = value
		if is_node_ready():
			shape.disabled = not is_active

@export var tile_coordinate: Vector2i
@export var buffer_index: int

func _ready() -> void:
	shape.disabled = not is_active
	var parent = get_parent()
	if parent is ConnectionManager:
		var manager = parent as ConnectionManager
		manager.setup.emit(self)

func handover(payload: NoteResource) -> void:
	incomming.emit(self, payload)

signal incomming(gate: ConnectionGate, payload: NoteResource)
