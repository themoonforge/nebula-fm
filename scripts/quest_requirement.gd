class_name QuestRequirement extends Resource

enum QuestSignal {
	BUILDINGS_PLACED,
	NOTE_PLAYED
}

@export var quest_signal: QuestSignal
@export var associated_building_name: String
@export var associated_note_name: String
@export var amount: int
@export var complete: bool
