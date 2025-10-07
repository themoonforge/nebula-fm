extends Node2D

@export var bpm: float = 120.0
@export var beats_per_bar: int = 4
#@export var regions: Array[Rect2] = []

var beat_timer: Timer
var beat_time: float = 0.0
var time_acc: float = 0.0

@export var note_texture: Texture

# just for tile map coord calculation
@export var ground_layer: TileMapLayer

#var map_manager

func _ready():
	beat_time = 60.0 / bpm  # Dauer einer Viertelnote in Sekunden
	#beat_timer = Timer.new()
	#beat_timer.wait_time = beat_time
	#beat_timer.autostart = true
	#beat_timer.timeout.connect(_on_beat)
	#add_child(beat_timer)
	
	#map_manager = get_parent().get_parent().get_parent().get_node("MapManager") # TODO improve this access!


func _process(delta: float) -> void:
	time_acc += delta
	if time_acc >= beat_time:
		_on_beat()
		time_acc = 0.0


func _on_beat():
	var dict = MapManager.map_data_c_collector as Dictionary[Vector2i, Node2D]
	for c_collector in dict.values():	
		spawn_note(c_collector.tile_coord)

func spawn_note(tile_coord: Vector2i):
	var note = load("res://scenes/map/note.tscn").instantiate()
	note.current_tile_coord = tile_coord
	note.previous_tile_coord = tile_coord
	note.modulate = Color(randf(), randf(), randf())
	#note.next_tile_coord = tile_coord

	%ConveyorBeltContainer.add_child(note)

	await get_tree().create_timer(1.0).timeout
	#sprite.queue_free()
	
