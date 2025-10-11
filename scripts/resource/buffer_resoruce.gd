class_name BufferResource extends Resource

# we don't have generics so we hard code the type

#@export var payload: NoteResource
var payload: NotePackage
@export var creation_time: int

#func _init(payload: NoteResource = null) -> void:
	#self.payload = payload
	#self.creation_time = Time.get_ticks_msec()

func _init(payload: NotePackage = null) -> void:
	self.payload = payload
	self.creation_time = Time.get_ticks_msec()
