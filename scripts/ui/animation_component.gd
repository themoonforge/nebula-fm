class_name AnimationComponent extends Node

@export var from_center : bool = true
@export var hover_scale : Vector2 = Vector2(1.1,1.1)
@export var pressed_scale : Vector2 = Vector2(0.9,0.9)
@export var time : float = 0.1
@export var transition_type : Tween.TransitionType

var target : Control
var default_scale : Vector2

func _ready() -> void:
	target = get_parent()
	connect_signals()
	call_deferred("setup")

func connect_signals() -> void:
	target.mouse_entered.connect(on_hover)
	target.mouse_exited.connect(off_hover)
	target.pressed.connect(on_pressed)

func setup() -> void:
	if from_center:
		target.anchor_left = 0.5
		target.anchor_right = 0.5
		target.pivot_offset = target.size / 2
	default_scale = target.scale

func on_hover() -> void:
	add_tween("scale", hover_scale, time)

func off_hover() -> void:
	add_tween("scale", default_scale, time)

func on_pressed() -> void:
	await add_tween("scale", pressed_scale, time, true)

	if target.is_hovered():
		add_tween("scale", hover_scale, time)
	else:
		add_tween("scale", default_scale, time)

func add_tween(property: String, value, seconds: float, wait_to_finish: bool = false) -> void:
	if not is_inside_tree():
		return
	var tween = get_tree().create_tween()
	tween.tween_property(target, property, value, seconds).set_trans(transition_type)
	if wait_to_finish:
		await tween.finished
