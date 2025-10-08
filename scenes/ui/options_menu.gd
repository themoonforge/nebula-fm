extends CanvasLayer

@onready var master_volume_slider: HSlider = %MasterVolumeSlider
@onready var music_volume_slider: HSlider = %MusicVolumeSlider
@onready var sfx_volume_slider: HSlider = %SFXVolumeSlider
@onready var options_close_button: Button = %OptionsCloseButton

func _ready() -> void:
	hide()
	options_close_button.pressed.connect(_on_options_close_button_pressed)
	music_volume_slider.value_changed.connect(_on_music_volume_slider_value_changed)
	master_volume_slider.value_changed.connect(_on_master_volume_slider_value_changed)
	sfx_volume_slider.value_changed.connect(_on_sfx_volume_slider_value_changed)
	_set_start_audio()
	
func _on_options_close_button_pressed() -> void:
	hide()
	
func _set_start_audio() -> void:
	master_volume_slider.value = 0.5
	music_volume_slider.value = 1.0
	sfx_volume_slider.value = 1.0
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(master_volume_slider.value))
		
func _on_master_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))
	
func _on_music_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value))

func _on_sfx_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(value))
