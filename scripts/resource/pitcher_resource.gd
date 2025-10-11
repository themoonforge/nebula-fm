class_name PitcherBuildingResource extends AbstractBuildingResource

@export var pitch: int = 0

enum PitchDirection {
	UP = 1,
	DOWN = -1,
	NONE = 0
}

## takes note from input buffer, pitches and puts it into the output buffer
func produce(input_buffer: Buffer, output_buffer: Buffer) -> void:
	var note = input_buffer.consume_first_note_from_buffer()
	if note != null:
		var pitched_keys: Array[int] = []
		for key in note.key_numbers:
			var pitched_note = pitch_note(key)	
			pitched_keys.append(pitched_note)
			
		note.key_numbers = pitched_keys
		output_buffer.add_element(note)

## pitches the note by the currently set pitch
func pitch_note(key: int) -> int:
	var pitched_key = key
	for i in range(0, absi(pitch)):
		pitched_key = _map_pitch(pitched_key, signi(pitch)) # -1, 0 or 1 -> pitch direction	
	return pitched_key

## pitches the key by 1 (down, or up) while skipping the flats (#)
func _map_pitch(key: int, pitch_direction: PitchDirection = 0) -> int:
	match(key % 12):
		0:
			var changed_key = key + max(2 * pitch_direction, -1)
			key = max(changed_key, 0) # C <-> D | 0 is key limit
		1:
			key += pitch_direction # C# <-> D
		2:
			key += 2 * pitch_direction # D <-> E		
		3:
			key += pitch_direction # D# <-> E		
		4:
			if pitch_direction < 1:
				key -= 2 # E -> D	
			else:
				key += 1 # E -> F	
		5:
			key += max(-1, 2 * pitch_direction) # F <-> G		
		6:
			key += pitch_direction # F# <-> G	
		7:
			var changed_key = key + (2 * pitch_direction)	
			key = min(changed_key, 127) # G <-> A | 127 key limit
		8:
			key += pitch_direction # G# <-> A		
		9:
			key += 2 * pitch_direction # A <-> B					
		10:
			key += pitch_direction # A# <-> B					
		11:
			if pitch_direction < 1:
				key -= 2 # B -> A	
			else:
				key += 1 # B -> C
		_:
			key = 60
			print("Note set to fallback (C) due to some key mapping error")
	return key		
