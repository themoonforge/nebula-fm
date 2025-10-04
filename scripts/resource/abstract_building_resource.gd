@abstract class_name AbstractBuildingResource extends Resource

@export var name: StringName:
	set(value):
		name = value
		resource_name = value

@export var size: Vector2i:
	set(value):
		if value.x < 0 or value.y < 0:
			printerr("invalid size for ", name, " of ", value)
			return
		size = value

# coordinates in the tile set for back- and foreground
@export var background_tile: Vector2i
@export var foreground_tile: Vector2i

# offsets of input / output location in relation to tile_coordinate (root location)
@export var input_locations: Array[Vector2i]
@export var output_locations: Array[Vector2i]

@export var production_time: float = 0.0

@abstract func produce(input_buffer: Buffer, output_buffer: Buffer) -> void