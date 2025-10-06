extends CharacterBody2D

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var emote: Sprite2D = %Emote

var current_animation_index: int = 0
var animation_names: Array = ["right_down", "left_down", "left_up", "right_up"]

func _ready() -> void:
	emote.self_modulate.a = 0.0
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	if animation_names.size() > 0:
		animation_player.play(animation_names[current_animation_index])

func _on_mouse_entered() -> void:
	show_emote(emote.texture)
	
func _on_mouse_exited() -> void:
	hide_emote()
	
func show_emote(texture: Texture2D) -> void:
	emote.texture = texture
	emote.self_modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(emote, "self_modulate:a", 1.0, 0.5)
	
func hide_emote() -> void:
	emote.self_modulate.a = 1.0
	var tween = create_tween()
	tween.tween_property(emote, "self_modulate:a", 0.0, 0.5)
	await tween.finished

func _process(delta: float) -> void:
	_loop_animations()
	
func _loop_animations() -> void:
	if not animation_player.is_playing():
		current_animation_index = (current_animation_index + 1) % animation_names.size()
		
		animation_player.play(animation_names[current_animation_index])
