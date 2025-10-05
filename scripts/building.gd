@tool
class_name Building extends Area2D

const BUILDING_TILE_SET = 2

@export var building_resource: AbstractBuildingResource = null:
	set(value):
		building_resource = value
		if is_node_ready():
			_setup_resource()

@export var building_rotation: BuildingsUtils.BuildingRotation = BuildingsUtils.BuildingRotation.DOWN:
	set(value):
		if building_resource.has_rorations:
			building_rotation = value
		else:
			building_rotation = BuildingsUtils.BuildingRotation.DOWN
		if is_node_ready():
			_setup_resource()

@export var ground_size: Vector2i = Vector2i.ZERO

@onready var input_buffer: Buffer = %InputBuffer
@onready var output_buffer: Buffer = %OutputBuffer
@onready var background: TileMapLayer = %Background
@onready var foreground: TileMapLayer = %Foreground
@onready var connectionIndicators: TileMapLayer = %ConnectionIndicators
@onready var label: Label = %Label
@onready var groundCollisionPolygon: CollisionPolygon2D = %GroundCollisionPolygon2D
@onready var shapeCollisionPolygon: CollisionPolygon2D = %ShapeCollisionPolygon2D


@export var show_connection_indicators: bool = false:
	set(value):
		show_connection_indicators = value
		if is_node_ready():
			connectionIndicators.visible = value


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

#@export var shape: ConcavePolygonShape2D = ConcavePolygonShape2D.new()

@export var is_active: bool = false:
	set(value):
		is_active = value
		if is_node_ready():
			_handle_active()

func _ready() -> void:
	_setup_resource()
	_handle_active()

func _process(delta: float) -> void:
	if Engine.is_editor_hint() || not is_active:
		return

	production_time += delta
	if production_time >= building_resource.production_time:
		production_time = 0.0
		building_resource.produce(input_buffer, output_buffer)

func _setup_indicators(connections: Dictionary[Vector2i, BuildingsUtils.BuildingRotation]) -> void:
	for connection in connections:
		#print("_setup_indicators: ", connection)
		var arrow = BuildingsUtils.rotationToArrow(connections[connection])
		var coordinate = BuildingsUtils.rotateTileBy(connection, building_rotation, building_resource.size, ground_size)
		var rotated_arrow = BuildingsUtils.rotateArrowBy(arrow, building_rotation)
		connectionIndicators.set_cell(coordinate, BUILDING_TILE_SET, rotated_arrow)

func _setup_resource() -> void:
	background.clear()
	foreground.clear()
	connectionIndicators.clear()

	ground_size = BuildingsUtils.rotateSize(building_resource.size, building_rotation)

	var rotation_offset = BuildingsUtils.rotationToOffset(building_rotation)
	var atlas_coordinate = building_resource.background_tile + rotation_offset
	background.set_cell(Vector2i.ZERO, BUILDING_TILE_SET, atlas_coordinate)
	var tile_data: TileData = background.get_cell_tile_data(Vector2i.ZERO)
	var groundPoints: PackedVector2Array = tile_data.get_collision_polygon_points(0, 0)
	groundCollisionPolygon.polygon = groundPoints
	var shapePoints: PackedVector2Array = tile_data.get_collision_polygon_points(1, 0)
	shapeCollisionPolygon.polygon = shapePoints

	_setup_indicators(building_resource.input_locations)
	_setup_indicators(building_resource.output_locations)
	connectionIndicators.visible = show_connection_indicators
	label.text = building_resource.label()


func _handle_active() -> void:
		if is_active:
			self.add_to_group(BuildingsUtils.BUILDING_GROUP)
		else:
			self.remove_from_group(BuildingsUtils.BUILDING_GROUP)
		
		connectionIndicators.visible = not is_active
		background.collision_enabled = is_active
		background.modulate = Color.WHITE
		foreground.modulate = Color.WHITE
		shapeCollisionPolygon.disabled = not is_active
		groundCollisionPolygon.disabled = is_active

func modulate_sprite(color: Color) -> void:
	background.modulate = color
	foreground.modulate = color
