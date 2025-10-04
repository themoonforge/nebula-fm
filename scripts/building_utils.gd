class_name BuildingsUtils extends Node

enum BuildingRotation {
	UP,
	RIGHT,
	DOWN,
	LEFT
}

static func rotationToOffset(building_rotation: BuildingRotation) -> Vector2i:
	match building_rotation:
		BuildingRotation.UP: return Vector2i(0, 0)
		BuildingRotation.RIGHT: return Vector2i(1, 0)
		BuildingRotation.DOWN: return Vector2i(2, 0)
		BuildingRotation.LEFT: return Vector2i(3, 0)
		_: return Vector2i.ZERO

static func rotationToName(building_rotation: BuildingRotation) -> StringName:
	match building_rotation:
		BuildingRotation.UP: return &"UP"
		BuildingRotation.RIGHT: return &"RIGHT"
		BuildingRotation.DOWN: return &"DOWN"
		BuildingRotation.LEFT: return &"LEFT"
		_: return &""

static func rightRotation(building_rotation: BuildingRotation) -> BuildingRotation:
	match building_rotation:
		BuildingRotation.UP: return BuildingRotation.RIGHT
		BuildingRotation.RIGHT: return BuildingRotation.DOWN
		BuildingRotation.DOWN: return BuildingRotation.LEFT
		BuildingRotation.LEFT: return BuildingRotation.UP
		_: return BuildingRotation.RIGHT
		
static func leftRotation(building_rotation: BuildingRotation) -> BuildingRotation:
	match building_rotation:
		BuildingRotation.UP: return BuildingRotation.LEFT
		BuildingRotation.RIGHT: return BuildingRotation.UP
		BuildingRotation.DOWN: return BuildingRotation.RIGHT
		BuildingRotation.LEFT: return BuildingRotation.DOWN
		_: return BuildingRotation.RIGHT
