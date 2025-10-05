class_name BuildingCursor extends Node2D

@onready var building: Building = %Building

@export var collider_dict: Dictionary[Node2D, int] = {}

signal on_collision(collision: bool)

func _ready() -> void:
	building.area_entered.connect(_on_area_entered)
	building.area_exited.connect(_on_area_exited)
	building.body_entered.connect(_on_body_entered)
	building.body_exited.connect(_on_body_exited)

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
	if not collider_dict.has(item):
		collider_dict[item] = 1
	else:
		collider_dict[item] += 1
	on_collision.emit(true)

func _decrement_collider(item: Node2D) -> void:
	if collider_dict.has(item):
		var value = collider_dict[item] - 1
		if value == 0:
			collider_dict.erase(item)
		else:
			collider_dict[item] = value
	on_collision.emit(collider_dict.size() > 0)
