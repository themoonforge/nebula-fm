class_name QuestInfo extends HBoxContainer

@onready var checked: TextureRect = %Checked
@onready var not_checked: TextureRect = %NotChecked
@onready var description: Label = %Description

var attached_quest_resource: QuestResource

func _ready() -> void:
	QuestTracker.quest_completed.connect(_on_quest_completed)
	checked.hide()
	
func _on_quest_completed(resource: QuestResource) -> void:
	if resource != attached_quest_resource:
		return
		
	not_checked.hide()
	checked.show()

func setup(quest_resource: QuestResource) -> void:
	attached_quest_resource = quest_resource
	description.text = quest_resource.description
