class_name TransformerGhost extends Node2D

@onready var sprite: Sprite2D = %Sprite2D
var transformer_scene: PackedScene
var transformer_resource: TransformerResource
var offset: Vector2i

func _ready() -> void:
	print("sprite ready")
