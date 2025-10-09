class_name Buffer extends Node

@export var _buffer: Dictionary[int, Array] = {}
@export var _last_filter_frame: int = 0
@export var _inventory: Dictionary[StringName, int] = {}

signal consume_note(note: NoteResource)
signal inventory_changed(inventory: Dictionary[StringName, int])

#func add_element(note: NoteResource, index: int = 0) -> void:
	#filter_old_buffer()
	#var buffer_resource: BufferResource = BufferResource.new(note)
	#
	#if not _buffer.has(index):
		#_buffer[index] = []
	#_buffer[index].append(buffer_resource)
	#_increment_inventory(note.simple_name)
	#inventory_changed.emit.call_deferred(_inventory)

# TODO remove

func add_element(note: NotePackage, index: int = 0) -> void:
	filter_old_buffer()
	var buffer_resource: BufferResource = BufferResource.new(note)
	
	if not _buffer.has(index):
		_buffer[index] = []
	_buffer[index].append(buffer_resource)
	if note:
		_increment_inventory(note.simple_name)
	inventory_changed.emit.call_deferred(_inventory)


func filter_old_buffer(time_offset_in_ms: int = 3000) -> void:
	var current_frame: int = Engine.get_frames_drawn()
	if current_frame == _last_filter_frame:
		return

	_last_filter_frame = current_frame
	var expiration_time: int = Time.get_ticks_msec() - time_offset_in_ms

	var changed: bool = false

	for buffer in _buffer:
		while not _buffer[buffer].is_empty() and _buffer[buffer][0].creation_time <= expiration_time:
			changed = true
			var expired_note_name: StringName = _buffer[buffer][0].simple_name
			_buffer[buffer].pop_front()
			_decrement_inventory(expired_note_name)

	if changed:
		inventory_changed.emit.call_deferred(_inventory)

func consume_note_from_buffer(key_number: int, index: int = 0) -> NoteResource:
	var found_elem: NoteResource = null

	# simple search
	var simple_name: String = MidiUtility.key_number_to_note_name(key_number)

	if not _buffer.has(index):
		_buffer[index] = []

	var elem_index: int = _buffer[index].find_custom(func(elem: NoteResource): return elem.simple_name == simple_name)
	if elem_index != -1:
		found_elem = _buffer[index][elem_index].payload
		_buffer[index].remove_at(elem_index)
		_decrement_inventory(simple_name)
		inventory_changed.emit.call_deferred(_inventory)
	return found_elem

#func consume_first_note_from_buffer(index: int = 0) -> NoteResource:
	#var found_elem: NoteResource = null
#
	#if not _buffer.has(index):
		#_buffer[index] = []
#
	#var first = _buffer[index].pop_front()
	#if first != null:
		#found_elem = first.payload
		#_decrement_inventory(first.simple_name)
	#return found_elem
	
func consume_first_note_from_buffer(index: int = 0) -> NotePackage:
	var found_elem: NotePackage = null

	if not _buffer.has(index):
		_buffer[index] = []

	var first = _buffer[index].pop_front()
	if first != null:
		found_elem = first.payload
		_decrement_inventory(first.simple_name)
	return found_elem

func _increment_inventory(item_name: StringName) -> void:
	if not _inventory.has(item_name):
		_inventory[item_name] = 1
	else:
		_inventory[item_name] += 1

func _decrement_inventory(item_name: StringName) -> void:
	if _inventory.has(item_name):
		var value = _inventory[item_name] - 1
		if value == 0:
			_inventory.erase(item_name)
		else:
			_inventory[item_name] = value
