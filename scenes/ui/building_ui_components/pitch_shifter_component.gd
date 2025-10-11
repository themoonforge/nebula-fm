class_name PitchShifterComponent extends BuildingUiComponent

signal pitch_shifted(new_pitch: int)

@onready var shift_up: Button = %ShiftUp
@onready var shift_down: Button = %ShiftDown

var current_pitch: int

func set_up(building: Building) -> void:
	super._set_up(building)
	
func _ready() -> void:
	shift_up.pressed.connect(_on_shift_up_pressed)
	shift_down.pressed.connect(_on_shift_down_pressed)
	
func _on_shift_up_pressed() -> void:
	pitch_shifted.emit(1)
	
func _on_shift_down_pressed() -> void:
	pitch_shifted.emit(-1)
