class_name TransformerGhost extends Node2D

@onready var sprite: Sprite2D = %Sprite2D
var transformer_scene: PackedScene

func _ready() -> void:
	print("sprite ready")
