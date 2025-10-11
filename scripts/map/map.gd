class_name Map extends Node2D

@export var building_scene: PackedScene
@export var mister_nebula: PackedScene
@export var radio_station_resource: SpaceRadioResource
@export var note_source_scene: PackedScene
@export var camera: GameCamera
@onready var ground_layer: TileMapLayer = %GroundLayer
@onready var small_blob_layer: TileMapLayer = %SmallBlobLayer
@onready var water_layer: TileMapLayer = %WaterLayer
@onready var big_blob_layer: TileMapLayer = %BigBlobLayer
@onready var obstacles_layer: TileMapLayer = %ObstaclesLayer
@onready var border_layer: TileMapLayer = %BorderLayer
@onready var crater_layer: TileMapLayer = %CraterLayer
@onready var dust_layer: TileMapLayer = %DustLayer
@onready var note_sources_layer: TileMapLayer = %NoteSourcesLayer
@onready var placed_objects: Node2D = %Objects
@onready var noise_rect: TextureRect = %NoiseRect
@onready var midi_player: MidiPlayer = %GodotMIDIPlayer
@onready var conveyor_belt_manager: ConveyorBeltManager = %ConveyorBeltManager

var noise_texture: NoiseTexture2D
var noise_grid: Dictionary[Vector2i, float]

var min_noise = INF
var max_noise = -INF

var tree_pattern_choices: Dictionary[int, Array]
var small_blob_pattern_choices: Dictionary[int, Array]
var big_blob_pattern_choices: Dictionary[int, Array]
var water_pattern_choices: Dictionary[int, Array]
var crater_pattern_choices: Dictionary[int, Array]

enum SubGrid {
	TOP_LEFT,
	TOP_RIGHT,
	BOTTOM_LEFT,
	BOTTOM_RIGHT
}

var station_subgrid: SubGrid

func _ready() -> void:	
	tree_pattern_choices[Tiles.SOURCE_2] = [
		Tiles.PATTERN_TREE_1, 
		Tiles.PATTERN_TREE_2,
		Tiles.PATTERN_TREE_3,
		Tiles.PATTERN_SHROOM_1,
		Tiles.PATTERN_SHROOM_2
	]
	
	small_blob_pattern_choices[Tiles.SOURCE_2] = [
		Tiles.PATTERN_BLOB_4,
		Tiles.PATTERN_BLOB_5
	]
	
	big_blob_pattern_choices[Tiles.SOURCE_2] = [
		Tiles.PATTERN_BLOB_1, 
		Tiles.PATTERN_BLOB_2,
		Tiles.PATTERN_BLOB_3
	]
	
	water_pattern_choices[Tiles.SOURCE_2] = [
		Tiles.PATTERN_PUDDLE_1, 
		Tiles.PATTERN_PUDDLE_2
	]
	
	crater_pattern_choices[Tiles.SOURCE_2] = [
		Tiles.PATTERN_CRATER_1, 
		Tiles.PATTERN_CRATER_2
	]
	
	generate()
	
	camera.bounds_rect = ground_layer.get_used_rect()
	camera.set_bounds()
	
	MapManager.regenerate.connect(_on_regenerate)
	MapManager.place_obstacle.connect(_on_place_obstacle)
	
func _on_regenerate() -> void:
	_regenerate()
		
func _on_place_obstacle(obstacle: Node2D) -> void:
	placed_objects.add_child(obstacle)
		
func _regenerate() -> void:
	conveyor_belt_manager.clear()
	MapManager.map_data_c_collector.clear()
	GridManager.free_grid()
	print("freed grid")
	MapManager.free_buildings()
	print("freed buildings")
	ground_layer.clear()
	print("cleared ground layer")
	small_blob_layer.clear()
	big_blob_layer.clear()
	print("cleared blob layer")
	obstacles_layer.clear()
	print("cleared obstacles layer")
	note_sources_layer.clear()
	print("cleared note sources layer")
	water_layer.clear()
	print("cleared water sources layer")
	crater_layer.clear()
	print("cleared crater sources layer")
	dust_layer.clear()
	print("cleared dust sources layer")
	for object in placed_objects.get_children():
		object.queue_free()
	
	await get_tree().physics_frame
	generate()
	print("called generate again")
		
func register_static_layer(layer: TileMapLayer) -> void:
	for y in Tiles.MAP_SIZE.y:
		for x in Tiles.MAP_SIZE.x:
			var cell: Vector2i = Vector2i(x, y)
			if Tiles.is_meta_tile(layer, cell, &"is_obstacle"):
				GridManager.set_cell(cell)

func generate() -> void:
	noise_texture = noise_rect.texture
	
	_generate_noise()
	
	_fill_layer(ground_layer, Tiles.SOURCE_2, Tiles.GROUND_4)
	_place_with_noise(dust_layer, Tiles.SOURCE_2, Tiles.DUST_1, Vector2(0.5, 0.55), 0.5)
	_place_with_noise(dust_layer, Tiles.SOURCE_2, Tiles.DUST_2, Vector2(0.55, 0.6), 0.5)
	_place_with_noise(dust_layer, Tiles.SOURCE_2, Tiles.DUST_3, Vector2(0.6, 0.65), 0.5)
	_place_with_noise(dust_layer, Tiles.SOURCE_2, Tiles.DUST_4, Vector2(0.65, 0.7), 0.5)
	register_static_layer(border_layer)
	_place_radio_station(SubGrid.values()[randi() % SubGrid.size()])
	_place_note_sources(6)
	_place_with_noise(obstacles_layer, Tiles.SOURCE_2, Tiles.ROCK_SMALL, Vector2(0.2, 0.25), 0.10)
	_place_patterns(crater_layer, crater_pattern_choices, Vector2(0.3, 0.5), 0.1)
	_place_patterns(water_layer, water_pattern_choices, Vector2(0.5, 0.6), 0.1)
	_place_patterns(big_blob_layer, big_blob_pattern_choices, Vector2(0.18, 0.19), 0.5)
	_place_patterns(small_blob_layer, small_blob_pattern_choices, Vector2(0.3, 0.5), 0.1)
	_place_patterns(obstacles_layer, tree_pattern_choices, Vector2(0.25, 0.3))
	
	GridManager.free_temporary_cells()
	
func _generate_noise() -> void:
	noise_texture.noise.seed = randi()
	# generate noise grid
	for y in Tiles.MAP_SIZE.y:
		for x in Tiles.MAP_SIZE.x:
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
	for y in Tiles.MAP_SIZE.y:
		for x in Tiles.MAP_SIZE.x:
			var cell: Vector2i = Vector2i(x, y)
			_set_cell(tile_map_layer, cell, source_id, tile_id)
			
func _place_radio_station(sub_grid: SubGrid) -> void:
	station_subgrid = sub_grid
	
	var sub_grid_rect = _get_subgrid_rect(sub_grid, Tiles.MAP_SIZE)
	var max_attempts = 100
	var spawn_cell: Vector2i = Vector2i(-1, -1)
	var cells_valid: bool = false
	
	var radio_station: Building = building_scene.instantiate()
	radio_station.building_resource = radio_station_resource
	radio_station.is_active = true
	radio_station.name = "Space_Radio_Station"
	placed_objects.add_child(radio_station)
	
	for attempt in max_attempts:
		spawn_cell = Vector2i(
			randi_range(sub_grid_rect.position.x + 2, sub_grid_rect.position.x + sub_grid_rect.size.x - radio_station.building_resource.size.x - 2),
			randi_range(sub_grid_rect.position.y + radio_station.building_resource.size.y + 2, sub_grid_rect.position.y + sub_grid_rect.size.y - 2)
		)
		
		match station_subgrid:
			SubGrid.TOP_LEFT:
				spawn_cell.y += 2
			SubGrid.BOTTOM_LEFT:
				spawn_cell.y -= 2
			SubGrid.TOP_RIGHT:
				spawn_cell.y += 2
			SubGrid.BOTTOM_RIGHT:
				spawn_cell.y -= 2
				
		cells_valid = true
		for y in radio_station_resource.size.y:
			for x in radio_station_resource.size.x:
				var cell_to_check = Vector2i(x, -y - 1) + spawn_cell
				if not GridManager.is_cell_free(cell_to_check):
					cells_valid = false
					break
			if not cells_valid:
				break
				
		if cells_valid:
			break
			
	if !cells_valid:
		Debug.debug_printerr("Could not find valid position for radio station in subgrid! Defaulting to cell 5,13.")
		spawn_cell = Vector2i(5, 13)
			
	radio_station.global_position = Vector2(spawn_cell * 16)
	radio_station.set_up_building_rect(spawn_cell)
	radio_station.set_up_shape_polygon(spawn_cell)

	for y in radio_station.building_resource.size.y:
		for x in radio_station.building_resource.size.x:
			GridManager.set_cell(Vector2i(x, -y - 1) + spawn_cell)
			
	_spawn_mister_nebula_fm(spawn_cell, radio_station)
			
func _spawn_mister_nebula_fm(station_spawn_cell: Vector2i, radio_station: Building) -> void:
	var mister_nebula_instance = mister_nebula.instantiate()
	mister_nebula_instance.name = "Mister_Nebula_FM"
	placed_objects.add_child(mister_nebula_instance)
	
	mister_nebula_instance.global_position = Vector2i(station_spawn_cell * 16)
	
	# Position Mister Nebula relative to the station based on subgrid
	match station_subgrid:
		SubGrid.TOP_LEFT:
			mister_nebula_instance.global_position.x += radio_station.building_resource.size.x * 16
			mister_nebula_instance.global_position.y -= 16
			mister_nebula_instance.global_position.x -= 16
		SubGrid.BOTTOM_LEFT:
			mister_nebula_instance.global_position.y -= radio_station.building_resource.size.y * 16
			mister_nebula_instance.global_position.x += radio_station.building_resource.size.y * 16
			mister_nebula_instance.global_position.x -= 16
		SubGrid.TOP_RIGHT:
			mister_nebula_instance.global_position.y -= 16
		SubGrid.BOTTOM_RIGHT:
			mister_nebula_instance.global_position.y -= radio_station.building_resource.size.x * 16

func _get_subgrid_rect(sub_grid, screen_size: Vector2) -> Rect2i:
	match sub_grid:
		SubGrid.TOP_LEFT:
			return Rect2i(0, 0, screen_size.x / 2, screen_size.y / 2)
		SubGrid.TOP_RIGHT:
			return Rect2i(screen_size.x / 2, 0, screen_size.x / 2, screen_size.y / 2)
		SubGrid.BOTTOM_LEFT:
			return Rect2i(0, screen_size.y / 2, screen_size.x / 2, screen_size.y / 2)
		SubGrid.BOTTOM_RIGHT:
			return Rect2i(screen_size.x / 2, screen_size.y / 2, screen_size.x / 2, screen_size.y / 2)
		_:
			return Rect2i(0, 0, screen_size.x / 2, screen_size.y / 2)
			
func _is_in_rect(cell: Vector2i, rect: Rect2i) -> bool:
	return rect.has_point(cell)

func _place_note_sources(count: int) -> void:		
	var grid_cols = Tiles.MAP_SIZE.x
	var grid_rows = Tiles.MAP_SIZE.y
	
	var grid_cells: Array[Vector2i] = []
	
	var station_rect = _get_subgrid_rect(station_subgrid, Tiles.MAP_SIZE)
	
	for col in range(0, grid_cols):
		for row in range(0, grid_rows):
			if _is_in_rect(Vector2i(col, row), station_rect) or !GridManager.is_cell_free(Vector2i(col, row)):
				continue
				
			grid_cells.append(Vector2i(col, row))
			
	grid_cells.shuffle()
	
	var placed_count = 0
	
	for grid_cell in grid_cells:
		if placed_count >= count:
			break
		var note_source: NoteSource = note_source_scene.instantiate()
		note_source.name = "NoteSource_At_" + str(grid_cell)
		placed_objects.add_child(note_source)
		var spawn_cell = Vector2i(grid_cell.x, grid_cell.y)
		note_source.global_position = Vector2(spawn_cell * 16)
		for cell in note_source.tiles.get_used_cells():
			GridManager.set_cell(cell + spawn_cell)
			MapManager.add_note_source(cell + spawn_cell)
			print("spawned note source")
		
		placed_count += 1

# todo: rewrite. this doesn't actually correctly always spawn count amount of note sources
#func _place_note_sources(tile_map_layer: TileMapLayer, source_id: int, tile_id: Vector2i, offset: Vector2i, count: int) -> void:
	#var screen_size = get_viewport_rect().size
	#
	#var grid_cols = int(screen_size.x / 16)
	#var grid_rows = int(screen_size.y / 16)
	#
	#var grid_cells: Array[Vector2i] = []
	#for row in range(0, grid_rows):
		#for col in range(0, grid_cols):
			#if row == 0 or col == 0 or row == grid_rows-1 or col == grid_cols-1:
				#continue
#
			#grid_cells.append(Vector2i(col, row))
	#
	#grid_cells.shuffle()
	#
	#var used_rows: Array[int] = []
	#var used_cols: Array[int] = []
	#var placed_count = 0
	#
	#for grid_cell in grid_cells:
		#if placed_count >= count:
			#break
			#
		#var cell = Vector2i(grid_cell.x, grid_cell.y)
		#
		#if cell.y in used_rows or cell.x in used_cols:
			#continue
		#
		#_set_cell(tile_map_layer, cell, source_id, tile_id)
		#used_rows.append(cell.y)
		#used_cols.append(cell.x)
		#placed_count += 1
			
func _place_with_noise(tile_map_layer: TileMapLayer, source_id: int, tile_id: Vector2i, noise_range: Vector2, placement_bias: float = 1.0) -> void:
	for y in Tiles.MAP_SIZE.y:
		for x in Tiles.MAP_SIZE.x:
			var cell: Vector2i = Vector2i(x, y)
			var raw_noise = absf(noise_grid[cell])
			var normalized = (raw_noise - min_noise) / (max_noise - min_noise)

			if normalized >= noise_range.x and normalized <= noise_range.y:
				var rng = randf()
				if rng <= placement_bias:
					_set_cell(tile_map_layer, cell, source_id, tile_id)
			else:
				continue
				
func _place_patterns(tile_map_layer: TileMapLayer, patterns: Dictionary[int, Array], noise_range: Vector2, placement_bias: float = 1.0) -> void:
	for y in Tiles.MAP_SIZE.y:
		for x in Tiles.MAP_SIZE.x:
			var pattern_source = patterns.keys()[randi() % patterns.size()]
			var pattern_array = patterns[pattern_source]
			var pattern_id = pattern_array[randi() % pattern_array.size()]
			
			var cell: Vector2i = Vector2i(x,y)
			var raw_noise = absf(noise_grid[cell])
			var normalized = (raw_noise - min_noise) / (max_noise - min_noise)

			if normalized >= noise_range.x and normalized <= noise_range.y:
				var rng = randf()
				if rng <= placement_bias:
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
		
		if Tiles.is_meta_tile(layer, cell_in_world, &"is_obstacle"):
			GridManager.set_cell(cell_in_world)
		if Tiles.is_meta_tile(layer, cell_in_world, &"is_generation_blocked"):
			GridManager.set_temporary_cell(cell_in_world)
	
	return true
	
func _pattern_fits(cell: Vector2i, pattern: TileMapPattern) -> bool:	
	for pattern_cell in pattern.get_used_cells():
		var cell_in_world: Vector2i = cell + pattern_cell
		
		if cell_in_world.x < 0 or cell_in_world.y < 0 or cell_in_world.x >= Tiles.MAP_SIZE.x or cell_in_world.y >= Tiles.MAP_SIZE.y:
			return false
			
		if !GridManager.is_cell_free(cell_in_world):
			return false
			
	return true

func _set_cell(layer: TileMapLayer, cell: Vector2i, source_id: int, tile_id: Vector2i) -> bool:
	if !GridManager.is_cell_free(cell):
		return false
	
	layer.set_cell(cell, source_id, tile_id)
	
	if Tiles.is_meta_tile(layer, cell, &"is_obstacle"):
		GridManager.set_cell(cell)
	elif Tiles.is_meta_tile(layer, cell, &"is_generation_blocked"):
		GridManager.set_temporary_cell(cell)
		
	return true
