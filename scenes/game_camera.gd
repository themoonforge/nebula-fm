class_name GameCamera extends Camera2D

@export var zoom_speed : float = 10
@export var drag_lerp_speed : float = 15.0

var zoom_target: Vector2
var position_target: Vector2

var drag_start_mouse_pos: Vector2 = Vector2.ZERO
var drag_start_camera_pos: Vector2 = Vector2.ZERO
var is_dragging: bool = false
var bounds_rect: Rect2i

func _ready():
	zoom_target = zoom
	position_target = position

func _process(delta):
	handle_zoom(delta)
	#simple_pan(delta)
	click_and_drag()
	lerp_to_target(delta)
	_clamp_position()
	
func handle_zoom(delta):
	if Input.is_action_just_pressed("camera_zoom_in"):
		zoom_target = (zoom_target * 1.1).clamp(Vector2(1.0, 1.0), Vector2(6.0, 6.0))
		
	if Input.is_action_just_pressed("camera_zoom_out"):
		zoom_target = (zoom_target * 0.9).clamp(Vector2(1.0, 1.0), Vector2(6.0, 6.0))
		
	zoom = zoom.slerp(zoom_target, zoom_speed * delta)
	
#func simple_pan(delta):
	#var move_amount = Vector2.ZERO
	#if Input.is_action_pressed("camera_move_right"):
		#move_amount.x += 1
		#
	#if Input.is_action_pressed("camera_move_left"):
		#move_amount.x -= 1
		#
	#if Input.is_action_pressed("camera_move_up"):
		#move_amount.y -= 1
		#
	#if Input.is_action_pressed("camera_move_down"):
		#move_amount.y += 1
		#
	#move_amount = move_amount.normalized()
	#position += move_amount * delta * 1000 * (1/zoom.x)
	
func click_and_drag():
	if !is_dragging and Input.is_action_just_pressed("camera_pan"):
		drag_start_mouse_pos = get_viewport().get_mouse_position()
		drag_start_camera_pos = position
		is_dragging = true
		
	if is_dragging and Input.is_action_just_released("camera_pan"):
		is_dragging = false
		
	if is_dragging:
		var move_vector = get_viewport().get_mouse_position() - drag_start_mouse_pos
		position_target = drag_start_camera_pos - move_vector * 1/zoom.x

func lerp_to_target(delta):
	position = position.lerp(position_target, drag_lerp_speed * delta)

func set_bounds() -> void:
	limit_left = bounds_rect.position.x * 16
	limit_right = bounds_rect.end.x * 16
	limit_top = bounds_rect.position.y * 16
	limit_bottom = bounds_rect.end.y * 16
	
func _clamp_position() -> void:
	var buffer_px = Vector2(240.0, 140.0)
	var buffer_world = buffer_px / zoom
	
	global_position.x = clamp(
		global_position.x,
		limit_left + buffer_world.x,
		limit_right - buffer_world.x
	)
	global_position.y = clamp(
		global_position.y,
		limit_top + buffer_world.y,
		limit_bottom - buffer_world.y
	)
	
	position_target.x = clamp(
		position_target.x,
		limit_left + buffer_world.x,
		limit_right - buffer_world.x
	)
	position_target.y = clamp(
		position_target.y,
		limit_top + buffer_world.y,
		limit_bottom - buffer_world.y
	)
