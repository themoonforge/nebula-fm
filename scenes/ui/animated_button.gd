extends Button

@export var new_background_color: Color
@export var new_font_color: Color

var normal_background_color: Color
var normal_font_color: Color
var normal_border_width_bottom: int
var normal_border_width_left: int
var normal_border_width_top: int
var normal_border_width_right: int

var normal_stylebox: StyleBoxFlat

func _ready() -> void:
	normal_stylebox = get_theme_stylebox("normal")
	
	if normal_stylebox is not StyleBoxFlat:
		Debug.debug_printerr("Animated button style box needs to be StyleBoxFlat.")
		return
	
	normal_border_width_bottom = normal_stylebox.border_width_bottom
	normal_border_width_left = normal_stylebox.border_width_left
	normal_border_width_top = normal_stylebox.border_width_top
	normal_border_width_right = normal_stylebox.border_width_right
	normal_background_color = normal_stylebox.bg_color
	normal_font_color = get_theme_color("font_color")
	
	animate()
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("rotate_right"):
		animate()
		print("hello")
	
func animate() -> void:
	var tween_to = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT).set_parallel(true)
	tween_to.tween_property(normal_stylebox, "bg_color", new_background_color, 0.5)
	#tween_to.tween_property(normal_stylebox, "border_width_bottom", 1.0, 0.5)
	#tween_to.tween_property(normal_stylebox, "border_width_left", 1.0, 0.5)
	#tween_to.tween_property(normal_stylebox, "border_width_top", 1.0, 0.5)
	#tween_to.tween_property(normal_stylebox, "border_width_right", 1.0, 0.5)
	tween_to.tween_method(_set_button_font_color, normal_font_color, new_font_color, 0.25)
	tween_to.chain()
		
	var tween_from = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT).set_parallel(true)
	tween_from.tween_property(normal_stylebox, "bg_color", normal_background_color, 0.75)
	#tween_from.tween_property(normal_stylebox, "border_width_bottom", 0, 0.5)
	#tween_from.tween_property(normal_stylebox, "border_width_left", 0, 0.5)
	#tween_from.tween_property(normal_stylebox, "border_width_top", 0, 0.5)
	#tween_from.tween_property(normal_stylebox, "border_width_right", 0, 0.5)
	tween_from.tween_method(_set_button_font_color, new_font_color, normal_font_color, 0.25)
	tween_from.chain()
	
	var final_tween = create_tween()
	final_tween.tween_subtween(tween_to)
	final_tween.tween_subtween(tween_from)
	final_tween.tween_subtween(tween_to)
	final_tween.tween_subtween(tween_from)

func _set_button_font_color(color: Color) -> void:
	add_theme_color_override("font_color", color)
