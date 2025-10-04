@tool
class_name Building extends Node2D

const BUILDING_TILE_SET = 2

@export var building_resource: AbstractBuildingResource = null:
	set(value):
		building_resource = value
		if is_node_ready():
			_setup_resurce()

@export var building_rotation: BuildingsUtils.BuildingRotation = BuildingsUtils.BuildingRotation.UP:
	set(value):
		building_rotation = value
		if is_node_ready():
			_setup_resurce()

@onready var input_buffer: Buffer = %InputBuffer
@onready var output_buffer: Buffer = %OutputBuffer
@onready var background: TileMapLayer = %Backgrond
@onready var foreground: TileMapLayer = %Foreground

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

func _ready() -> void:
	_setup_resurce()

func _process(delta: float) -> void:
	production_time += delta
	if production_time >= building_resource.production_time:
		production_time = 0.0
		building_resource.produce(input_buffer, output_buffer)

func _setup_resurce() -> void:
	var rotation_offset = BuildingsUtils.rotationToOffset(building_rotation)
	background.set_cell(Vector2i.ZERO, BUILDING_TILE_SET, building_resource.background_tile + rotation_offset)
	pass
