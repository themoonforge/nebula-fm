@tool
class_name BuildingsUtils extends Node

const ARROW_DOWN = Vector2i(8, 5)
const ARROW_RIGHT = Vector2i(9, 5)
const ARROW_UP = Vector2i(10, 5)
const ARROW_LEFT = Vector2i(11, 5)

const TILE_PX = 16
const HALF_TILE_PX = TILE_PX / 2

const BUILDING_GROUP = "BUILDINGS"

enum BuildingRotation {
	DOWN,
	RIGHT,
	UP,
	LEFT
}

static func rotateSize(ground_size: Vector2i, rotation: BuildingRotation) -> Vector2i:
	match rotation:
		BuildingRotation.DOWN: return ground_size
		BuildingRotation.RIGHT: return Vector2i(ground_size.y, ground_size.x)
		BuildingRotation.UP: return ground_size
		BuildingRotation.LEFT: return Vector2i(ground_size.y, ground_size.x)
		_: return ground_size

static func rotationToOffset(building_rotation: BuildingRotation) -> Vector2i:
	match building_rotation:
		BuildingRotation.DOWN: return Vector2i(0, 0)
		BuildingRotation.RIGHT: return Vector2i(1, 0)
		BuildingRotation.UP: return Vector2i(2, 0)
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

static func rotateTileBy(coordinate: Vector2i, rotation: BuildingRotation, original_ground_size: Vector2i, ground_size: Vector2i) -> Vector2i:
	var rotation_center = Vector2(original_ground_size.x, -original_ground_size.y) * HALF_TILE_PX
	var rotation_center_back = Vector2(ground_size.x, -ground_size.y) * HALF_TILE_PX

	var coord = Vector2(coordinate) * TILE_PX + Vector2(HALF_TILE_PX, -HALF_TILE_PX)

	var relative_coord = coord - rotation_center
	var rotated_relative_coord: Vector2
	match rotation:
		BuildingRotation.DOWN:
			rotated_relative_coord = relative_coord
		BuildingRotation.RIGHT:
			rotated_relative_coord = Vector2(relative_coord.y, -relative_coord.x)
		BuildingRotation.UP:
			rotated_relative_coord = Vector2(-relative_coord.x, -relative_coord.y)
		BuildingRotation.LEFT:
			rotated_relative_coord = Vector2(-relative_coord.y, relative_coord.x)
		_:
			rotated_relative_coord = relative_coord

	var final_coord = rotated_relative_coord - Vector2(HALF_TILE_PX, -HALF_TILE_PX) + rotation_center_back
	var final_tile_coord = Vector2i(roundi(final_coord.x / TILE_PX), roundi(final_coord.y / TILE_PX))
	return final_tile_coord

static func rotateArrowBy(arrow: Vector2i, rotation: BuildingRotation) -> Vector2i:
	match rotation:
		BuildingRotation.DOWN: return arrow
		BuildingRotation.RIGHT: return Vector2i((arrow.x + 1) % 4 + ARROW_DOWN.x, arrow.y)
		BuildingRotation.UP: return Vector2i((arrow.x + 2) % 4 + ARROW_DOWN.x, arrow.y)
		BuildingRotation.LEFT: return Vector2i((arrow.x + 3) % 4 + ARROW_DOWN.x, arrow.y)
		_: return arrow

static func rotationToArrow(rotation: BuildingRotation) -> Vector2i:
	match rotation:
		BuildingRotation.DOWN: return ARROW_DOWN
		BuildingRotation.RIGHT: return ARROW_RIGHT
		BuildingRotation.UP: return ARROW_UP
		BuildingRotation.LEFT: return ARROW_LEFT
		_: return ARROW_DOWN
