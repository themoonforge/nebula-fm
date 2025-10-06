class_name QuestRequirement extends Resource

enum QuestSignal {
	BUILDINGS_PLACED
}

@export var quest_signal: QuestSignal
@export var associated_building_name: String
@export var amount: int
@export var complete: bool
