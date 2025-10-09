class_name DeleteCursor extends Area2D

# TODO add area indicator

@export var hover_color: Color = Color(1.0, 0.0, 0.0, 0.549)

@onready var shape: CollisionShape2D = %CollisionShape2D

@export var collider_dict: Dictionary[Building, int] = {}

@export var is_active: bool = true:
	set(value):
		is_active = value
		if is_node_ready():
			shape.disabled = not is_active
			for building in collider_dict:
				building.modulate_sprite(hover_color if is_active else Color.WHITE)

signal on_collision(collision: bool)

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	shape.disabled = not is_active

func _on_body_entered(body: Node2D) -> void:
	_increment_collider(body)
	#print("_on_body_entered: ", body)

func _on_body_exited(body: Node2D) -> void:
	_decrement_collider(body)
	#print("_on_body_exited: ", body)

func _on_area_entered(area: Area2D) -> void:
	_increment_collider(area)
	#print("_on_area_entered: ", area)

func _on_area_exited(area: Area2D) -> void:
	_decrement_collider(area)
	#print("_on_area_exited: ", area)

func _increment_collider(item: Node2D) -> void:
	if item is Building:
		var building = item as Building
		if not building.is_active:
			return
		#print("_increment_collider: ", building)
		if not collider_dict.has(item):
			collider_dict[building] = 1
			building.modulate_sprite(hover_color if is_active else Color.WHITE)
		else:
			collider_dict[building] += 1
		on_collision.emit(true)

func _decrement_collider(item: Node2D) -> void:
	if item is Building:
		var building = item as Building
		#print("_decrement_collider: ", building)
		if collider_dict.has(item):
			var value = collider_dict[building] - 1
			if value == 0:
				collider_dict.erase(building)
				building.modulate_sprite(Color.WHITE)
			else:
				collider_dict[building] = value
		on_collision.emit(collider_dict.size() > 0)
