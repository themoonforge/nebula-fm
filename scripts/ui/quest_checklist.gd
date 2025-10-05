extends CanvasLayer

@export var quest_resources: Array[QuestResource]

var buildings_placed: int = 0

func _ready():
	MapManager.place_obstacle.connect(_on_place_buildings)

func _on_place_buildings(node: Node2D) -> void:
	buildings_placed += 1
	check_quest_completion("buildings_placed")

func check_quest_completion(signal_name : String) -> void:
	for resource in quest_resources:
		if resource.complete:
			continue
		for requirement in resource.requirements_array:
			if requirement.signal_name == signal_name && requirement.amount == buildings_placed:
				requirement.complete = true
				resource.completed_requirements.append(requirement)
			if resource.completed_requirements.size() == resource.requirements_array.size():
				resource.complete = true
