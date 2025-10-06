extends CanvasLayer

@onready var show_controls_button: Button = %ShowControlsButton
@onready var controls_panel: PanelContainer = %ControlsPanel

var button_style_normal: StyleBoxFlat
var button_style_hover: StyleBoxFlat

var is_hovering_button: bool

func _ready() -> void:
	button_style_normal = show_controls_button.get_theme_stylebox("normal")
	button_style_hover = show_controls_button.get_theme_stylebox("hover")
	
	controls_panel.hide()
	
	show_controls_button.mouse_entered.connect(_on_show_controls_button_mouse_entered)
	show_controls_button.mouse_exited.connect(_on_show_controls_button_mouse_exited)
	controls_panel.mouse_entered.connect(_on_controls_panel_mouse_entered)
	controls_panel.mouse_exited.connect(_on_controls_panel_mouse_exited)
	
func _on_show_controls_button_mouse_entered() -> void:
	controls_panel.show()
	is_hovering_button = true
	
func _on_show_controls_button_mouse_exited() -> void:
	controls_panel.hide()
	is_hovering_button = false
	show_controls_button.add_theme_stylebox_override("normal", button_style_normal)
	
func _on_controls_panel_mouse_entered() -> void:
	controls_panel.show()
	
	show_controls_button.add_theme_stylebox_override("normal", button_style_hover)
	
func _on_controls_panel_mouse_exited() -> void:
	await get_tree().create_timer(0.1).timeout
	if !is_hovering_button:
		controls_panel.hide()
		show_controls_button.add_theme_stylebox_override("normal", button_style_normal)
