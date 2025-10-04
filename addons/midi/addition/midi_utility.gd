class_name MidiUtility extends Object

const note_names: Dictionary[int, StringName] = {
	0: "C",
	1: "C#/Db",
	2: "D",
	3: "D#/Eb",
	4: "E",
	5: "F",
	6: "F#/Gb",
	7: "G",
	8: "G#/Ab",
	9: "A",
	10: "A#/Bb",
	11: "B"
}

const note_numbers: Dictionary[StringName, int] = {
	"C": 0,
	"C#": 1,
	"Db": 1,
	"C#/Db": 1,
	"D": 2,
	"D#": 3,
	"Eb": 3,
	"D#/Eb": 3,
	"E": 4,
	"F": 5,
	"F#": 6,
	"Gb": 6,
	"F#/Gb": 6,
	"G": 7,
	"G#": 8,
	"Ab": 8,
	"": 8,
	"A": 9,
	"A#": 10,
	"Bb": 10,
	"A#/Bb": 10,
	"B": 11
}

static func key_number_to_note_name(key_number: int) -> String:
	var note = key_number % 12
	return note_names[note]

static func key_number_to_note_name_with_octave(key_number: int) -> String:
	var octave = floor(key_number / 12) - 1
	var note = key_number % 12
	return note_names[note] + str(octave)