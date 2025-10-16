class_name QuestRequirement extends Resource

enum QuestSignal {
	BUILDINGS_PLACED,
	NOTE_PLAYED,
	NOTE_TRANSMITTED,
	RADIO_SONGS_FINISHED
}

@export var quest_signal: QuestSignal
@export var associated_building_name: StringName
@export var associated_note_name: StringName
@export var associated_song_name: StringName
@export var amount: int
@export var complete: bool
