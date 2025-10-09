@tool
class_name CollectorBuildingResource extends AbstractBuildingResource

var note_scene = preload("res://scenes/map/note.tscn")

#@export var note: NoteResource = null:
	#set(value):
		#note = value

# TYPE OF THE note		
#var note: NotePackage = null:
	#set(value):
		#note = value
##var key_number: int = 0:
#set(value):
	#note = value

func produce(input_buffer: Buffer, output_buffer: Buffer) -> void:
	var note = note_scene.instantiate() as NotePackage
	note.simple_name = "C"
	note.key_number = 60
	output_buffer.add_element(note)
	
	#print("produce: ", note.simple_name)

#func _to_string() -> String:
	#if note:
		#return note.simple_name
	#return ""
