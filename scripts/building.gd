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
			

func _ready() -> void:
	beat_time = 60.0 / MapManager.global_bpm # TODO use global bpm from conveyor belt manager once it is global
	_setup_resource()
	#_handle_active()

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
		
	for connection_tile in outputs.connection_dict:
		var connection_gate = outputs.connection_dict[connection_tile]
		var found_elem = output_buffer.consume_first_note_from_buffer(connection_gate.buffer_index)
		if found_elem != null:
			#print("fround elem: ", found_elem)
			connection_gate.handover(found_elem)

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
	
# TODO move this to note.tscn ... im stupido	
@export var c_texture: Texture
@export var d_texture: Texture
@export var e_texture: Texture
@export var f_texture: Texture
@export var g_texture: Texture
@export var a_texture: Texture
@export var b_texture: Texture
@export var package_texture: Texture


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

	if note.key_numbers.size() == 1:
		match(note.key_numbers[0]):
			60:
				note.get_child(0).texture = c_texture
			62:
				note.get_child(0).texture = d_texture
			64:
				note.get_child(0).texture = e_texture
	else:
		note.get_child(0).texture = package_texture
				
	note.name = "Note_" + str(Time.get_unix_time_from_system())	
	# TODO improve access!
	var conveyor_belt_container = get_node("/root/Game/Map/ConveyorBeltManager/ConveyorBeltContainer") 
	conveyor_belt_container.add_child(note)
	
#endregion
