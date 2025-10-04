@tool
class_name Building extends Node2D

@export var building_resource: AbstractBuildingResource = null

@onready var input_buffer: Buffer = %InputBuffer

@onready var output_buffer: Buffer = %OutputBuffer

@export var production_time: float = 0.0:
	set(value):
		production_time = value
		if building_resource.production_time > 0:
			current_production_percentage = min(1, value / building_resource.production_time)
		else:
			current_production_percentage = -1

@export var current_production_percentage: float = 0.0:
	set(value):
		current_production_percentage = value

# map of connection based on input and output locations
@export var input_connections: Dictionary[Vector2i, AbstractBuildingResource]
@export var output_connections: Dictionary[Vector2i, AbstractBuildingResource]

func _process(delta: float) -> void:
	production_time += delta
	if production_time >= building_resource.production_time:
		production_time = 0.0
		building_resource.produce(input_buffer, output_buffer)
