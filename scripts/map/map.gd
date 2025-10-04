class_name Map extends Node2D

@onready var ground_layer: TileMapLayer = %GroundLayer
@onready var obstacles_layer: TileMapLayer = %ObstaclesLayer
@onready var note_sources_layer: TileMapLayer = %NoteSourcesLayer
@onready var placed_objects: Node2D = %Objects
@onready var noise_rect: TextureRect = %NoiseRect

var noise_texture: NoiseTexture2D
var noise_grid: Dictionary[Vector2i, float]

var min_noise = INF
var max_noise = -INF

var tree_pattern_choices: Dictionary[int, Array]

func _ready() -> void:
	tree_pattern_choices[Tiles.SOURCE_1] = [
		Tiles.PATTERN_TREE_1, 
		Tiles.PATTERN_TREE_2,
		Tiles.PATTERN_TREE_3,
		Tiles.PATTERN_TREE_4
	]
	
	generate()
	
	MapManager.place_obstacle.connect(_on_place_obstacle)
	
func _on_place_obstacle(obstacle: Node2D) -> void:
	placed_objects.add_child(obstacle)
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed(&"generate"):
		GridManager.free_grid()
		MapManager.free_buildings()
		ground_layer.clear()
		obstacles_layer.clear()
		note_sources_layer.clear()
		for object in placed_objects.get_children():
			object.queue_free()
			
		generate()

func generate() -> void:
	noise_texture = noise_rect.texture
	
	_generate_noise()
	
	_fill_layer(ground_layer, Tiles.SOURCE_0, Tiles.GROUND_0)
	_place_note_sources(note_sources_layer, Tiles.SOURCE_2, Tiles.NOTE_SOURCE, Vector2i(5, 5), 4)
	_place_with_noise(obstacles_layer, Tiles.SOURCE_0, Tiles.ROCK_SMALL, Vector2(0.2, 0.25))
	_place_patterns(obstacles_layer, tree_pattern_choices, Vector2(0.25, 0.3))
	
func _generate_noise() -> void:
	noise_texture.noise.seed = randi()
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

func _fill_layer(tile_map_layer: TileMapLayer, source_id: int, tile_id: Vector2i) -> void:
	for y in get_viewport_rect().size.y / 16:
		for x in get_viewport_rect().size.x / 16:
			var cell: Vector2i = Vector2i(x, y)
			_set_cell(tile_map_layer, cell, source_id, tile_id)
			
func _place_note_sources(tile_map_layer: TileMapLayer, source_id: int, tile_id: Vector2i, offset: Vector2i, count: int) -> void:
	var valid_cells: Array[Vector2i] = []
	var screen_size = get_viewport_rect().size / 16
	
	for y in range(0, screen_size.y):
		for x in range(0, screen_size.y):
			var cell: Vector2i = Vector2i(x, y)
			if GridManager.is_cell_free(cell):
				valid_cells.append(cell)
	
	valid_cells.shuffle()
	
	var placed_cells: Array[Vector2i] = []
	for candidate in valid_cells:
		var too_close = false
		
		for placed in placed_cells:
			if abs(candidate.x - placed.x) < offset.x or abs(candidate.y - placed.y) < offset.y:
				too_close = true
				break
		if too_close:
			continue
			
		_set_cell(tile_map_layer, candidate, source_id, tile_id)
		placed_cells.append(candidate)
		print("placed cell at: ", candidate)
		
		if placed_cells.size() >= count:
			break
			
func _place_with_noise(tile_map_layer: TileMapLayer, source_id: int, tile_id: Vector2i, noise_range: Vector2) -> void:
	for y in get_viewport_rect().size.y / 16:
		for x in get_viewport_rect().size.x / 16:
			var cell: Vector2i = Vector2i(x, y)
			var raw_noise = absf(noise_grid[cell])
			var normalized = (raw_noise - min_noise) / (max_noise - min_noise)

			if normalized >= noise_range.x and normalized <= noise_range.y:
				_set_cell(tile_map_layer, cell, source_id, tile_id)
			else:
				continue
				
func _place_patterns(tile_map_layer: TileMapLayer, patterns: Dictionary[int, Array], noise_range: Vector2) -> void:
	for y in get_viewport_rect().size.y / 16:
		for x in get_viewport_rect().size.x / 16:
			var pattern_source = patterns.keys()[randi() % patterns.size()]
			var pattern_array = patterns[pattern_source]
			var pattern_id = pattern_array[randi() % pattern_array.size()]
			
			var cell: Vector2i = Vector2i(x,y)
			var raw_noise = absf(noise_grid[cell])
			var normalized = (raw_noise - min_noise) / (max_noise - min_noise)

			if normalized >= noise_range.x and normalized <= noise_range.y:
				_set_pattern(tile_map_layer, cell, pattern_source, pattern_id)
			else:
				continue
				
func _set_pattern(layer: TileMapLayer, cell: Vector2i, source_id: int, pattern_id: int) -> bool:
	var pattern = layer.tile_set.get_pattern(pattern_id)
	
	if !_pattern_fits(cell, pattern):
		return false
	
	layer.set_pattern(cell, pattern)
	
	for pattern_cell in pattern.get_used_cells():
		var cell_in_world: Vector2i = cell + pattern_cell
		GridManager.set_cell(cell_in_world)
	
	return true
	
func _pattern_fits(cell: Vector2i, pattern: TileMapPattern) -> bool:
	for pattern_cell in pattern.get_used_cells():
		var cell_in_world: Vector2i = cell + pattern_cell
		if !GridManager.is_cell_free(cell_in_world):
			return false
			
	return true

func _set_cell(layer: TileMapLayer, cell: Vector2i, source_id: int, tile_id: Vector2i) -> bool:
	if !GridManager.is_cell_free(cell):
		return false
	
	layer.set_cell(cell, source_id, tile_id)
	
	if is_obstacle_tile(layer, cell):
		GridManager.set_cell(cell)
		
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
