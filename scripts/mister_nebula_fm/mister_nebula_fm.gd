extends CharacterBody2D

@export var emote_heart: Texture2D
@export var emote_note: Texture2D

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var emote: Sprite2D = %Emote

var animation_names: Array = ["right_down", "left_down", "left_up", "right_up"]
var current_direction: String = ""

func _ready() -> void:
	MapManager.place_building.connect(_on_place_building)
	
	emote.self_modulate.a = 0.0
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	_turn_to_mouse()
	
func _on_place_building(building: Building) -> void:
	show_emote(emote_note)
	
func _process(delta: float) -> void:
	_turn_to_mouse()
	
func _turn_to_mouse() -> void:
	var mouse_pos = get_global_mouse_position()
	var dir = global_position.direction_to(mouse_pos)
	
	var new_direction: String = ""
	
	if abs(dir.x) > abs(dir.y):
		if dir.x > 0:
			new_direction = "right_down" if dir.y > 0 else "right_up"
		else:
			new_direction = "left_down" if dir.y > 0 else "left_up"
	else:
		if dir.y > 0:
			new_direction = "right_down" if dir.x > 0 else "left_down"
		else:
			new_direction = "right_up" if dir.x > 0 else "left_up"
	
	if new_direction != current_direction:
		current_direction = new_direction
		animation_player.play(current_direction)

func _on_mouse_entered() -> void:
	show_emote(emote_heart)
	
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
