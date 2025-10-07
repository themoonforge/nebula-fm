extends CanvasLayer

@onready var show_controls_button: Button = %ShowControlsButton
@onready var reset_button: Button = %ResetGameButton
@onready var you_sure_button: Button = %YouSureButton
@onready var actually_no_button: Button = %ActuallyNoButton
@onready var controls_panel: PanelContainer = %ControlsPanel
@onready var build_mode_label: Label = %BuildModeLabel
@onready var delete_mode_label: Label = %DeleteModeLabel

var button_style_normal: StyleBoxFlat
var button_style_hover: StyleBoxFlat

var is_hovering_button: bool

func _ready() -> void:
	delete_mode_label.hide()
	build_mode_label.hide()
	MapManager.build_mode_change.connect(_on_build_mode_changed)

	you_sure_button.hide()
	actually_no_button.hide()
	button_style_normal = show_controls_button.get_theme_stylebox("normal")
	button_style_hover = show_controls_button.get_theme_stylebox("hover")
	
	controls_panel.hide()
	
	show_controls_button.mouse_entered.connect(_on_show_controls_button_mouse_entered)
	show_controls_button.mouse_exited.connect(_on_show_controls_button_mouse_exited)
	controls_panel.mouse_entered.connect(_on_controls_panel_mouse_entered)
	controls_panel.mouse_exited.connect(_on_controls_panel_mouse_exited)
	
	reset_button.pressed.connect(_on_reset_pressed)
	you_sure_button.pressed.connect(_on_you_sure_button_pressed)
	actually_no_button.pressed.connect(_on_actually_no_button)
	
func _on_build_mode_changed(mode: MapManager.Mode) -> void:
	match mode:
		MapManager.Mode.BUILD:
			build_mode_label.show()
			delete_mode_label.hide()
		MapManager.Mode.DELETE:
			build_mode_label.hide()
			delete_mode_label.show()
		_:
			build_mode_label.hide()
			delete_mode_label.hide()
	
func _on_reset_pressed() -> void:
	you_sure_button.show()
	actually_no_button.show()
	reset_button.hide()
	
func _on_actually_no_button() -> void:
	you_sure_button.hide()
	actually_no_button.hide()
	reset_button.show()
	
func _on_you_sure_button_pressed() -> void:
	actually_no_button.hide()
	you_sure_button.hide()
	reset_button.show()
	MapManager.regenerate.emit()
	
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
