class_name Map extends Node2D

@export var radio_station_scene: PackedScene
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
		print("SHOULD GENERATE")
		
		GridManager.free_grid()
		print("freed grid")
		MapManager.free_buildings()
		print("freed buildings")
		ground_layer.clear()
		print("cleared ground layer")
		obstacles_layer.clear()
		print("cleared obstacles layer")
		note_sources_layer.clear()
		print("cleared note sources layer")
		for object in placed_objects.get_children():
			object.queue_free()
		
		await get_tree().physics_frame
		generate()
		print("called generate again")

func generate() -> void:
	print("inside generated, called it")
	
	noise_texture = noise_rect.texture
	
	_generate_noise()
	
	_fill_layer(ground_layer, Tiles.SOURCE_0, Tiles.GROUND_0)
	_place_radio_station()
	_place_note_sources(note_sources_layer, Tiles.SOURCE_2, Tiles.NOTE_SOURCE, Vector2i(6, 6), 3)
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

func _place_radio_station() -> void:
	var radio_station: RadioStation = radio_station_scene.instantiate()
	placed_objects.add_child(radio_station)
	
	var screen_size = get_viewport_rect().size / 16
	var station_rect = radio_station.tiles.get_used_rect()
	
	var spawn_cell = Vector2i(
		randi_range(0, int(screen_size.x) - station_rect.size.x),
		randi_range(0, int(screen_size.y) - station_rect.size.y)
	)
	
	radio_station.global_position = Vector2(spawn_cell * 16)
	
	for cell in radio_station.tiles.get_used_cells():
		GridManager.set_cell(cell + spawn_cell)

func _place_note_sources(tile_map_layer: TileMapLayer, source_id: int, tile_id: Vector2i, offset: Vector2i, count: int) -> void:
	var screen_size = get_viewport_rect().size
	
	var grid_cols = int(screen_size.x / 16)
	var grid_rows = int(screen_size.y / 16)
	
	var grid_cells: Array[Vector2i] = []
	for row in range(0, grid_rows):
		for col in range(0, grid_cols):
			if row == 0 or col == 0 or row == grid_rows-1 or col == grid_cols-1:
				continue

			grid_cells.append(Vector2i(col, row))
	
	grid_cells.shuffle()
	
	var used_rows: Array[int] = []
	var used_cols: Array[int] = []
	var placed_count = 0
	
	for grid_cell in grid_cells:
		if placed_count >= count:
			break
			
		var cell = Vector2i(grid_cell.x, grid_cell.y)
		
		if cell.y in used_rows or cell.x in used_cols:
			continue
		
		_set_cell(tile_map_layer, cell, source_id, tile_id)
		used_rows.append(cell.y)
		used_cols.append(cell.x)
		placed_count += 1
			
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
	var screen_size = get_viewport_rect().size / 16
	
	for pattern_cell in pattern.get_used_cells():
		var cell_in_world: Vector2i = cell + pattern_cell
		
		if cell_in_world.x < 0 or cell_in_world.y < 0 or cell_in_world.x >= screen_size.x or cell_in_world.y >= screen_size.y:
			return false
			
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
