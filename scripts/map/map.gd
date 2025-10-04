class_name Map extends Node2D

@onready var ground_layer: TileMapLayer = %GroundLayer
@onready var obstacles_layer: TileMapLayer = %ObstaclesLayer
@onready var placed_objects: Node2D = %Objects

func _ready() -> void:
	generate()
	
	MapManager.place_obstacle.connect(_on_place_obstacle)
	
func _on_place_obstacle(obstacle: Node2D) -> void:
	placed_objects.add_child(obstacle)

func generate() -> void:
	_fill_layer(ground_layer, Tiles.GROUND_0)
	_place_scattered(obstacles_layer, Tiles.ROCK_SMALL)

func _fill_layer(tile_map_layer: TileMapLayer, tile_id: Vector2i) -> void:
	for y in get_viewport_rect().size.y / 16:
		for x in get_viewport_rect().size.x / 16:
			var cell: Vector2i = Vector2i(x, y)
			_set_cell(tile_map_layer, cell, tile_id)
			
func _place_scattered(tile_map_layer: TileMapLayer, tile_id: Vector2i) -> void:
	for y in get_viewport_rect().size.y / 16:
		for x in get_viewport_rect().size.x / 16:
			var rng: float = randf()
			if rng <= 0.7:
				continue
			var cell: Vector2i = Vector2i(x, y)
			_set_cell(tile_map_layer, cell, tile_id)

func _set_cell(layer: TileMapLayer, cell: Vector2i, tile_id: Vector2i) -> bool:
	if !GridManager.is_cell_free(cell):
		print("Cell ", cell, " not free.")
		return false
	
	layer.set_cell(cell, Tiles.SOURCE, tile_id)
	
	if is_obstacle_tile(layer, cell):
		GridManager.set_cell(cell)
		print("Cell ", cell, " marked as set.")
		
	return true

func is_obstacle_tile(layer: TileMapLayer, cell: Vector2i) -> bool:
	var tile_data: TileData = layer.get_cell_tile_data(cell)
	if !tile_data:
		return false
		
	if tile_data && tile_data.has_custom_data(&"is_obstacle"):
		var is_obstacle: bool = tile_data.get_custom_data(&"is_obstacle")
		if is_obstacle:
			return true
			
	return false
