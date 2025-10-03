extends CanvasLayer

@onready var start_button: Button = %StarGameButton
@onready var options_open_button: Button = %OptionsOpenButton
@onready var options_close_button: Button = %OptionsCloseButton
@onready var credits_open_button: Button = %CreditsOpenButton
@onready var credits_close_button: Button = %CreditsCloseButton

@onready var options_screen: CanvasLayer = %Options
@onready var credits_screen: CanvasLayer = %Credits

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_button.pressed.connect(_on_start_button_pressed)
	options_open_button.pressed.connect(_on_options_open_button_pressed)
	options_close_button.pressed.connect(_on_options_close_button_pressed)
	credits_open_button.pressed.connect(_on_credits_open_button_pressed)
	credits_close_button.pressed.connect(_on_credits_close_button_pressed)
	
	options_screen.hide()
	credits_screen.hide()
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed(&"ui_exit"):
		options_screen.hide()
		credits_screen.hide()

func _on_start_button_pressed() -> void:
	pass
	
func _on_options_open_button_pressed() -> void:
	options_screen.show()
	
func _on_options_close_button_pressed() -> void:
	options_screen.hide()
	
func _on_credits_open_button_pressed() -> void:
	credits_screen.show()
	
func _on_credits_close_button_pressed() -> void:
	credits_screen.hide()
