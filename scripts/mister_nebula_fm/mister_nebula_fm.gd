extends Node2D

@onready var animation_player: AnimationPlayer = %AnimationPlayer

var current_animation_index: int = 0
var animation_names: Array = ["right_down", "left_down", "left_up", "right_up"]

func _ready() -> void:
	if animation_names.size() > 0:
		animation_player.play(animation_names[current_animation_index])

func _process(delta: float) -> void:
	_loop_animations()
	
func _loop_animations() -> void:
	if not animation_player.is_playing():
		current_animation_index = (current_animation_index + 1) % animation_names.size()
		
		animation_player.play(animation_names[current_animation_index])
