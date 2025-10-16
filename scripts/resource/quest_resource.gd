class_name QuestResource extends Resource

@export var description: String
@export var requirements_array: Array[QuestRequirement]
var completed_requirements: Array[QuestRequirement]
@export var complete: bool = false
@export var is_tutorial: bool = false
