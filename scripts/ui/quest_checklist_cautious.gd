extends CanvasLayer

@export var quest_resources: Array[QuestResource]
@export var quest_container: PackedScene

@onready var v_box_container: VBoxContainer = $MarginContainer/VBoxContainer

var buildings_placed: int = 0

func _ready():
	update_quests()
	MapManager.place_building.connect(_on_placed_building)

func update_quests():
	for child in v_box_container.get_children():
		if child.name == "Label":
			continue
		child.queue_free()
	for quest in quest_resources:
		for requirement in quest.requirements_array:
			var new_quest_container = quest_container.instantiate()
			v_box_container.add_child(new_quest_container)
			var quest_description = quest.description
			var remaining = max(0, requirement.amount - buildings_placed)
			quest_description = quest_description.replace("{x}", str(remaining))
			new_quest_container.rich_text_label.text = quest_description
			if requirement in quest.completed_requirements:
				new_quest_container.rich_text_label.text = "[s]" + quest_description + "[/s]"
				new_quest_container.check_box.button_pressed = true

func _on_placed_building(building: Node2D) -> void:
	buildings_placed += 1
	check_quest_completion("buildings_placed")

func check_quest_completion(signal_name : String) -> void:
	for resource in quest_resources:
		if resource.complete:
			continue
		for requirement in resource.requirements_array:
			if requirement.signal_name == signal_name && buildings_placed >= requirement.amount:
				if requirement not in resource.completed_requirements:
					requirement.complete = true
					resource.completed_requirements.append(requirement)
		if resource.completed_requirements.size() == resource.requirements_array.size():
			resource.complete = true
			MusicPlayer.play_sfx("ui_click_confirm")
			print("Quest Complete!")
	update_quests()
