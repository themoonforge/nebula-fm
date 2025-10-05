class_name GameCamera extends Node2D

@export var zoom_speed: float = 0.1
@export var camera: Camera2D

var bounds_rect: Rect2i
var is_mouse_pressed: bool

func _ready() -> void:
	camera.zoom = Vector2(1,1)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and is_mouse_pressed:
		global_position -= event.relative
		_clamp_position()
		
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			is_mouse_pressed = event.pressed
			
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera.zoom *= 1 + zoom_speed
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera.zoom *= 1 - zoom_speed
		camera.zoom = camera.zoom.clamp(Vector2(1.0, 1.0), Vector2(6.0, 6.0))
		_clamp_position()

func set_bounds() -> void:
	camera.limit_left = bounds_rect.position.x * 16
	camera.limit_right = bounds_rect.end.x * 16
	camera.limit_top = bounds_rect.position.y * 16
	camera.limit_bottom = bounds_rect.end.y * 16

func _clamp_position() -> void:
	var viewport_size = get_viewport().get_visible_rect().size
	var half_viewport = viewport_size / 2.0
	
	global_position.x = clamp(
		global_position.x,
		camera.limit_left,
		camera.limit_right
	)
	global_position.y = clamp(
		global_position.y,
		camera.limit_top,
		camera.limit_bottom
	)
