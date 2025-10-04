class_name Map extends Node2D

@onready var ground_layer: TileMapLayer = %GroundLayer
@onready var obstacles_layer: TileMapLayer = %ObstaclesLayer
@onready var placed_objects: Node2D = %Objects
@onready var noise_rect: TextureRect = %NoiseRect

var noise_texture: NoiseTexture2D
var noise_grid: Dictionary[Vector2i, float]

var min_noise = INF
var max_noise = -INF

func _ready() -> void:
	generate()
	
	MapManager.place_obstacle.connect(_on_place_obstacle)
	
func _on_place_obstacle(obstacle: Node2D) -> void:
	placed_objects.add_child(obstacle)

func generate() -> void:
	noise_texture = noise_rect.texture
	
	# generate noise grid
	for y in get_viewport_rect().size.y / 16:
		for x in get_viewport_rect().size.x / 16:
			var cell: Vector2i = Vector2i(x, y)
			noise_grid[cell] = noise_texture.noise.get_noise_2d(x, y)
	
	# normalise noise grid
	for cell in noise_grid:
		var val = absf(noise_grid[cell])
		if val < min_noise:
			min_noise = val
		if val > max_noise:
			max_noise = val
	
	_fill_layer(ground_layer, Tiles.GROUND_0)
	_place_with_noise(obstacles_layer, Tiles.ROCK_SMALL, Vector2(0.2, 0.3))

func _fill_layer(tile_map_layer: TileMapLayer, tile_id: Vector2i) -> void:
	for y in get_viewport_rect().size.y / 16:
		for x in get_viewport_rect().size.x / 16:
			var cell: Vector2i = Vector2i(x, y)
			_set_cell(tile_map_layer, cell, tile_id)
			
func _place_with_noise(tile_map_layer: TileMapLayer, tile_id: Vector2i, noise_range: Vector2) -> void:
	for y in get_viewport_rect().size.y / 16:
		for x in get_viewport_rect().size.x / 16:
			var cell: Vector2i = Vector2i(x, y)
			var raw_noise = absf(noise_grid[cell])
			var normalized = (raw_noise - min_noise) / (max_noise - min_noise)

			if normalized >= noise_range.x and normalized <= noise_range.y:
				_set_cell(tile_map_layer, cell, tile_id)
			else:
				continue

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
