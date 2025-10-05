class_name BufferResource extends Resource

# we don't have generics so we hard code the type

@export var payload: NoteResource
@export var creation_time: int

@export var simple_name: StringName = "":
	get():
		return payload.simple_name

func _init(payload: NoteResource = null) -> void:
	self.payload = payload
	self.creation_time = Time.get_ticks_msec()
