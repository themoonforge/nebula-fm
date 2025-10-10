#@tool
class_name Building extends Area2D

@export var beats_per_bar: int = 4
#@export var regions: Array[Rect2] = []

var beat_timer: Timer
var beat_time: float = 0.0
var time_acc: float = 0.0

# just for tile map coord calculation
@export var ground_layer: TileMapLayer

var note_scene = preload("res://scenes/map/note.tscn")
var tile_coord: Vector2i # location on the tilemap
var output_locations: Array[Vector2i]

#region bognari

const BUILDING_TILE_SET = 2

enum ConnectionType {
	INPUT, OUTPUT
}

signal note_produced(note: NotePackage)

@export var building_resource: AbstractBuildingResource = null:
	set(value):
		building_resource = value
		if is_node_ready():
			_setup_resource()

@export var building_rotation: BuildingsUtils.BuildingRotation = BuildingsUtils.BuildingRotation.DOWN:
	set(value):
		if building_resource.has_rotation:
			building_rotation = value
		else:
			building_rotation = BuildingsUtils.BuildingRotation.DOWN
		if is_node_ready():
			_setup_resource()

@export var connection_scene: PackedScene

@export var ground_size: Vector2i = Vector2i.ZERO

@onready var input_buffer: Buffer = %InputBuffer
@onready var output_buffer: Buffer = %OutputBuffer

@onready var background: TileMapLayer = %Background
@onready var foreground: TileMapLayer = %Foreground

@onready var connectionIndicators: TileMapLayer = %ConnectionIndicators
@onready var label: Label = %Label
@onready var groundCollisionPolygon: CollisionPolygon2D = %GroundCollisionPolygon2D
@onready var shapeCollisionPolygon: CollisionPolygon2D = %ShapeCollisionPolygon2D
@onready var inputs: ConnectionManager = %Inputs
@onready var outputs: ConnectionManager = %Outputs

@onready var building_ui: BuildingUi = %BuildingUi

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

@export var is_active: bool = false:
	set(value):
		is_active = value
		if is_node_ready():
			print("is active node is ready")
			_handle_active()

var building_rect: Rect2i
var building_shape_polygon: PackedVector2Array
			
func _ready() -> void:
	beat_time = 60.0 / MapManager.global_bpm # TODO use global bpm from conveyor belt manager once it is global
	_setup_resource()
	
	MapManager.place_building.connect(_on_place_building)
	MapManager.click_building.connect(_on_click_building)
		
	building_ui.setup(self)
	building_ui.hide()
	building_rect = Rect2i(tile_coord.x*Tiles.TILE_PX, tile_coord.y*Tiles.TILE_PX, ground_size.x*Tiles.TILE_PX, ground_size.y*Tiles.TILE_PX)

func _process(delta: float) -> void:
	time_acc += delta
	#if time_acc >= beat_time:
		#match(building_resource.building_key):
			#"pitcher":
				#pass
			#"c_collector":
				#pass
					#
		#time_acc = 0.0
			
	#if Engine.is_editor_hint() || not is_active:
		#return

	#production_time += delta
	#print("production_time: ", production_time)
	#if production_time >= building_resource.production_time:
	if time_acc >= beat_time:
		time_acc = 0.0
		
		#production_time = 0.0
		# TODO fix
		#print("input: ", input_buffer)
		
		# check if the building is actually placed
		if get_parent() is not BuildingCursor:
			# PRODUCE (put NotePackage in input buffer, transform, and put to output buffer)
			building_resource.produce(input_buffer, output_buffer)
			# take note out of the buffer
			var note = output_buffer.consume_first_note_from_buffer()
			if note != null:
				spawn_note_from_output_buffer(note)
				note_produced.emit(note)
		
	for connection_tile in outputs.connection_dict:
		var connection_gate = outputs.connection_dict[connection_tile]
		var found_elem = output_buffer.consume_first_note_from_buffer(connection_gate.buffer_index)
		if found_elem != null:
			#print("fround elem: ", found_elem)
			connection_gate.handover(found_elem)
			
	if MapManager.mode != MapManager.Mode.IDLE:
		return
		
	_handle_ui()
	
	if building_ui.visible:
		building_ui.update()

func _on_click_building(building: Building) -> void:
	if building != self:
		building_ui.hide()
		return
	
	building_ui.show()
			
func _on_place_building(building: Building) -> void:
	building_ui.hide()
	building_ui.is_hovered = false
			
func set_up_building_rect(tile: Vector2i) -> void:
	tile_coord = tile
	
	building_rect = Rect2i(tile_coord.x*Tiles.TILE_PX, tile_coord.y*Tiles.TILE_PX, ground_size.x*Tiles.TILE_PX, ground_size.y*Tiles.TILE_PX)
		
func set_up_shape_polygon(tile: Vector2i) -> void:
	tile_coord = tile
	
	var tile_world_pos = Vector2(tile_coord.x * Tiles.TILE_PX, tile_coord.y * Tiles.TILE_PX)
	
	for point in shapeCollisionPolygon.polygon:
		var polygon_point = tile_world_pos + point
		building_shape_polygon.append(polygon_point + Vector2(Tiles.TILE_PX, -Tiles.TILE_PX) - shapeCollisionPolygon.position)

func _handle_ui() -> void:
	var mouse_pos = get_viewport().get_mouse_position()
	var canvas_transform = get_viewport().get_canvas_transform()
	var world_mouse_pos = canvas_transform.affine_inverse() * mouse_pos
	
	var mouse_in_bottom: bool = building_rect.position.y >= get_viewport().get_visible_rect().size.y/2
	
	if Geometry2D.is_point_in_polygon(world_mouse_pos, building_shape_polygon):
		if !building_ui.visible:
			# align ui with top right of tile
			building_ui.position.x = building_rect.size.x - building_resource.size.x*16
			
			var building_x = global_position.x + building_ui.position.x + building_ui.size.x
			var overlap_x = building_x - get_viewport().get_visible_rect().size.x+Tiles.TILE_PX
			
			if building_x >= get_viewport().get_visible_rect().size.x+Tiles.TILE_PX:
				building_ui.position.x -= overlap_x
			
			if mouse_in_bottom:
				# ui top center of building
				building_ui.position.y = -building_rect.size.y/2 - building_ui.size.y - Tiles.TILE_PX/2
			else:
				# ui bottom center of building
				building_ui.position.y = -building_rect.size.y/2 - building_ui.size.y + Tiles.TILE_PX/2 + building_ui.size.y# - Tiles.HALF_TILE_PX/2
	
			if Input.is_action_just_pressed("ui_click"):
				building_ui.size = building_ui.get_child(0).size
				MapManager.click_building.emit(self)
	elif building_ui.visible && !building_ui.is_hovered:
			print("hide here")
			building_ui.hide()

func _setup_connections(connections: Dictionary[Vector2i, BuildingsUtils.BuildingRotation], connection_type: ConnectionType) -> void:
	var nodes: Array[Node] = []
	match connection_type:
		ConnectionType.INPUT:
			inputs.clear()
			nodes = inputs.get_children()
		ConnectionType.OUTPUT:
			outputs.clear()
			nodes = outputs.get_children()
	
	for node in nodes:
		node.queue_free()
					
	output_locations.clear()
					
	var i: int = -1
	for connection in connections:
		i += 1
		#print("_setup_indicators: ", connection)
		var arrow = BuildingsUtils.rotationToArrow(connections[connection])
		var coordinate = BuildingsUtils.rotateTileBy(connection, building_rotation, building_resource.size, ground_size)
		
		if connection_type == ConnectionType.OUTPUT:
			output_locations.append(coordinate)
		
		var rotated_arrow = BuildingsUtils.rotateArrowBy(arrow, building_rotation)
		connectionIndicators.set_cell(coordinate, BUILDING_TILE_SET, rotated_arrow)
		_generate_connetion_gate(coordinate, connection_type, i)

func _generate_connetion_gate(tile_coordinate: Vector2i, connection_type: ConnectionType, buffer_index: int) -> void:
	var connection_gate_position = background.map_to_local(tile_coordinate)
	
	var connection_gate: ConnectionGate = connection_scene.instantiate()
	connection_gate.is_active = is_active 
	connection_gate.mode = connection_type
	connection_gate.tile_coordinate = tile_coordinate
	connection_gate.buffer_index = buffer_index
	
	connection_gate.incomming.connect(_on_incoming, Object.ConnectFlags.CONNECT_DEFERRED)
	
	match connection_type:
		ConnectionType.INPUT:
			inputs.add_child(connection_gate)
		ConnectionType.OUTPUT:
			outputs.add_child(connection_gate)
	
	connection_gate.position = connection_gate_position

func _setup_resource() -> void:
	background.clear()
	foreground.clear()
	connectionIndicators.clear()

	ground_size = BuildingsUtils.rotateSize(building_resource.size, building_rotation)

	var rotation_offset = BuildingsUtils.rotationToOffset(building_rotation, building_resource.rotation_offset)
	var atlas_coordinate = building_resource.background_tile + rotation_offset
	background.set_cell(Vector2i.ZERO, BUILDING_TILE_SET, atlas_coordinate)
	var tile_data: TileData = background.get_cell_tile_data(Vector2i.ZERO)
	var groundPoints: PackedVector2Array = tile_data.get_collision_polygon_points(0, 0)
	groundCollisionPolygon.polygon = groundPoints
	var shapePoints: PackedVector2Array = tile_data.get_collision_polygon_points(1, 0)
	shapeCollisionPolygon.polygon = shapePoints
	
	label.text = str(building_resource)
	_setup_connections(building_resource.input_locations, ConnectionType.INPUT)
	_setup_connections(building_resource.output_locations, ConnectionType.OUTPUT)
	connectionIndicators.visible = show_connection_indicators

func _handle_active() -> void:
	print("handle active called")
	if is_active:
		self.add_to_group(BuildingsUtils.BUILDING_GROUP)
	else:
		self.remove_from_group(BuildingsUtils.BUILDING_GROUP)
	connectionIndicators.visible = not is_active
	background.collision_enabled = is_active
	modulate_sprite(Color.WHITE)
	shapeCollisionPolygon.disabled = not is_active
	groundCollisionPolygon.disabled = is_active
	
	for input in inputs.get_children():
		if input is ConnectionGate:
			input.is_active = is_active
	for output in outputs.get_children():
		if output is ConnectionGate:
			output.is_active = is_active

func modulate_sprite(color: Color) -> void:
	background.modulate = color
	foreground.modulate = color

#func _on_incoming(gate: ConnectionGate, payload: NoteResource) -> void:
	##print("_on_incoming : ", gate, " ", payload)
	#input_buffer.add_element(payload)
	
#endregion

#region chariot

func _on_incoming(gate: ConnectionGate, payload: NotePackage) -> void:
	#if building_resource.building_key == "space_radio_station":
	input_buffer.add_element(payload, gate.buffer_index)

## called when input containers receives new areas with shapes
#func _on_inputs_child_entered_tree(node: Node) -> void:
	#if node is Area2D:
		#node.area_entered.connect(_note_received)

#func _note_received():
	#pass

## Puts NotePackage from buffer on the conveyor belt 
func spawn_note_from_output_buffer(note: NotePackage):
	#print("NOTE KEY: ", note.simple_name)
	if building_resource.input_locations.keys().size() > 0:
		note.previous_tile_coord = note.current_tile_coord
	
	note.current_tile_coord = tile_coord
	
	if output_locations.size() > 0:
		note.current_tile_coord += output_locations[0]

		#var location: Vector2i = building_resource.input_locations.keys()[0]
		#note.previous_tile_coord = location

	note.get_child(0).texture = note.get_texture()
				
	note.name = "Note_" + str(Time.get_unix_time_from_system())	
	# TODO improve access!
	var conveyor_belt_container = get_node("/root/Game/Map/ConveyorBeltManager/ConveyorBeltContainer") 
	conveyor_belt_container.add_child(note)
	
#endregion
