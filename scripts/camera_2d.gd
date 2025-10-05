class_name GameCamera extends Camera2D

@export var zoom_speed: float = 0.1

var bounds_rect: Rect2i

func _ready() -> void:
	pass

func _input(event: InputEvent) -> void:
	pass
	#print(event)

func set_bounds() -> void:
	limit_left = bounds_rect.position.x * 16 / zoom.x
	limit_right = bounds_rect.end.x * 16 / zoom.x
	limit_top = bounds_rect.position.y * 16 / zoom.y
	limit_bottom = bounds_rect.end.y * 16 / zoom.y

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom *= 1 + zoom_speed
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom *= 1 - zoom_speed
		zoom = zoom.clamp(Vector2(1.0, 1.0), Vector2(6.0, 6.0))
		set_bounds()
