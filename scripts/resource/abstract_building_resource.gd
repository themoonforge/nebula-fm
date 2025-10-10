@abstract class_name AbstractBuildingResource extends Resource

@export var name: StringName:
	set(value):
		name = value
		resource_name = value

# search key for dictionaries (building type)	
@export var building_key: StringName

@export var description: String


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
@export var input_locations: Dictionary[Vector2i, BuildingsUtils.BuildingRotation]
@export var output_locations: Dictionary[Vector2i, BuildingsUtils.BuildingRotation]

@export var has_rotation: bool = true
@export var production_time: float = 0.0

@export var hotbar_icon: Texture2D
@export var hotbar_icon_hovered: Texture2D

@export var rotation_offset: Array[Vector2i] = []

## take smth from input buffer, transform, put result into output buffer
@abstract func produce(input_buffer: Buffer, output_buffer: Buffer) -> void
