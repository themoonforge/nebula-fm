@tool
class_name MidiInputNoteResource extends Resource

@export var key_number: int = 0:
	set(value):
		key_number = value
		name = MidiUtility.key_number_to_note_name_with_octave(key_number)
		resource_name = name
		simple_name = MidiUtility.key_number_to_note_name(key_number)
		simple_name_flat_up = MidiUtility.key_number_to_note_name_flat_up(key_number)
		simple_name_flat_down = MidiUtility.key_number_to_note_name_flat_down(key_number)

@export var creation_time: int

@export var name: StringName = &""
@export var simple_name: StringName = &""
@export var simple_name_flat_up: StringName = &""
@export var simple_name_flat_down: StringName = &""

func _equals(other: int) -> bool:
	var up = MidiUtility.key_number_to_note_name_flat_up(other)
	var down = MidiUtility.key_number_to_note_name_flat_down(other)
	return simple_name_flat_up == up or simple_name_flat_down == down 

func _init(key_number: int = 0) -> void:
	self.key_number = key_number
	self.creation_time = Time.get_ticks_msec()
