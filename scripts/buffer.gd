class_name Buffer extends Node

@export var _buffer: Array[BufferResource] = []

@export var _last_filter_frame: int = 0

@export var _inventory: Dictionary[StringName, int] = {}

signal consume_note(note: NoteResource)
signal inventory_changed(inventory: Dictionary[StringName, int])

func add_element(note: NoteResource) -> void:
	filter_old_input_buffer()
	_buffer.append(note)
	_increment_inventory(note.simple_name)
	inventory_changed.emit.call_deferred(_inventory)

func filter_old_input_buffer(time_offset_in_ms: int = 1000) -> void:
	var current_frame: int = Engine.get_frames_drawn()
	if current_frame == _last_filter_frame:
		return

	_last_filter_frame = current_frame
	var expiration_time: int = Time.get_ticks_msec() - time_offset_in_ms

	var changed: bool = false

	while not _buffer.is_empty() and _buffer[0].creation_time <= expiration_time:
		changed = true
		var expired_note_name: StringName = _buffer[0].simple_name
		_buffer.pop_front()
		_decrement_inventory(expired_note_name)

	if changed:
		inventory_changed.emit.call_deferred(_inventory)

func consume_note_from_input_buffer(key_number: int) -> NoteResource:
	var found_elem: NoteResource = null

	# simple search
	var simple_name: String = MidiUtility.key_number_to_note_name(key_number)

	var index: int = _buffer.find_custom(func(elem: NoteResource): return elem.simple_name == simple_name)
	if index != -1:
		found_elem = _buffer[index].payload
		_buffer.remove_at(index)
		_decrement_inventory(simple_name)
		inventory_changed.emit.call_deferred(_inventory)
	return found_elem

func consume_first_note_from_input_buffer() -> NoteResource:
	var found_elem: NoteResource = null

	var first = _buffer.pop_front()
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