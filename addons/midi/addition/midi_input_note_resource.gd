@tool
class_name MidiInputNoteResource extends Resource

@export var key_number: int = 0:
	set(value):
		key_number = value
		name = MidiUtility.key_number_to_note_name_with_octave(key_number)
		resource_name = name
		simple_name = MidiUtility.key_number_to_note_name(key_number)

@export var creation_time: int

@export var name: StringName = ""
@export var simple_name: StringName = ""

func _init(key_number: int = 0) -> void:
	self.key_number = key_number
	self.creation_time = Time.get_ticks_msec()
