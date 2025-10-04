extends CanvasLayer

@onready var start_button: Button = %StartGameButton
@onready var options_open_button: Button = %OptionsOpenButton
@onready var options_close_button: Button = %OptionsCloseButton
@onready var credits_open_button: Button = %CreditsOpenButton
@onready var credits_close_button: Button = %CreditsCloseButton

@onready var options_screen: CanvasLayer = %Options
@onready var credits_screen: CanvasLayer = %Credits

@onready var master_volume_slider: HSlider = %MasterVolumeSlider
@onready var music_volume_slider: HSlider = %MusicVolumeSlider

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_button.pressed.connect(_on_start_button_pressed)
	options_open_button.pressed.connect(_on_options_open_button_pressed)
	options_close_button.pressed.connect(_on_options_close_button_pressed)
	credits_open_button.pressed.connect(_on_credits_open_button_pressed)
	credits_close_button.pressed.connect(_on_credits_close_button_pressed)
	
	music_volume_slider.value_changed.connect(_on_music_volume_slider_value_changed)
	master_volume_slider.value_changed.connect(_on_master_volume_slider_value_changed)
	
	_set_start_audio()
	
	options_screen.hide()
	credits_screen.hide()
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed(&"ui_exit"):
		options_screen.hide()
		credits_screen.hide()
		
func _set_start_audio() -> void:
	master_volume_slider.value = 0.5
	music_volume_slider.value = 1.0
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(master_volume_slider.value))
		
func _on_master_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))
	
func _on_music_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value))

func _on_start_button_pressed() -> void:
	SceneTransition.transition_scene("res://scenes/game.tscn")
	
func _on_options_open_button_pressed() -> void:
	options_screen.show()
	
func _on_options_close_button_pressed() -> void:
	options_screen.hide()
	
func _on_credits_open_button_pressed() -> void:
	credits_screen.show()
	
func _on_credits_close_button_pressed() -> void:
	credits_screen.hide()
