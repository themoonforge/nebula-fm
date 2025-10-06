extends CanvasLayer

@export var quest_resources: Array[QuestResource]
@export var quest_info_scene: PackedScene
@onready var quest_info_container: Container = %QuestInfoContainer
@onready var tutorial_panel: Container = %TutorialPanel
@onready var show_tutorial_button: Button = %ShowTutorialButton

var buildings_placed: Dictionary[String, int]
var notes_played: Dictionary[String, int]

var button_style_normal: StyleBoxFlat
var button_style_hover: StyleBoxFlat

var is_hovering_button: bool

func _ready() -> void:
	QuestTracker.quest_completed.connect(_on_quest_complete)
	
	tutorial_panel.hide()
	
	button_style_normal = show_tutorial_button.get_theme_stylebox("normal")
	button_style_hover = show_tutorial_button.get_theme_stylebox("hover")
	
	show_tutorial_button.mouse_entered.connect(_on_show_tutorial_button_mouse_entered)
	show_tutorial_button.mouse_exited.connect(_on_show_tutorial_button_mouse_exited)
	tutorial_panel.mouse_entered.connect(_on_tutorial_panel_mouse_entered)
	tutorial_panel.mouse_exited.connect(_on_tutorial_panel_mouse_exited)
	
	EventBus.note_played.connect(_on_note_played)
	MapManager.place_building.connect(_on_placed_building)
	_render_quest_info_items()
	
func _on_quest_complete(quest_resource: QuestResource) -> void:
	# todo just fade an icon in or something
	pass
	
func _on_note_played(note_resource: MidiInputNoteResource) -> void:
	check_quest_completion(QuestRequirement.QuestSignal.NOTE_PLAYED)

func _set_button_font_color(color: Color) -> void:
	show_tutorial_button.add_theme_color_override("font_color", color)
	
func _on_show_tutorial_button_mouse_entered() -> void:
	tutorial_panel.show()
	is_hovering_button = true
	
func _on_show_tutorial_button_mouse_exited() -> void:
	tutorial_panel.hide()
	is_hovering_button = false
	show_tutorial_button.add_theme_stylebox_override("normal", button_style_normal)
	
func _on_tutorial_panel_mouse_entered() -> void:
	tutorial_panel.show()
	
	show_tutorial_button.add_theme_stylebox_override("normal", button_style_hover)
	
func _on_tutorial_panel_mouse_exited() -> void:
	await get_tree().create_timer(0.1).timeout
	if !is_hovering_button:
		tutorial_panel.hide()
		show_tutorial_button.add_theme_stylebox_override("normal", button_style_normal)
	
func _render_quest_info_items() -> void:
	for resource in quest_resources:
		var quest_info_instance: QuestInfo = quest_info_scene.instantiate()
		quest_info_container.add_child(quest_info_instance)
		quest_info_instance.setup(resource)

func _on_placed_building(building: Node2D) -> void:
	check_quest_completion(QuestRequirement.QuestSignal.BUILDINGS_PLACED, building)

func check_quest_completion(quest_signal : QuestRequirement.QuestSignal, building: Building = null) -> void:
	for resource in quest_resources:
		if resource.complete:
			continue
		for requirement in resource.requirements_array:
			if building:
				if requirement.associated_building_name != building.building_resource.name:
					continue
			
			var mapped_required_amount = _increase_required_amount(requirement)
			
			if requirement.quest_signal == quest_signal && requirement.amount == mapped_required_amount:
				requirement.complete = true
				resource.completed_requirements.append(requirement)
			if resource.completed_requirements.size() == resource.requirements_array.size():
				resource.complete = true
				QuestTracker.quest_completed.emit(resource)

func _increase_required_amount(requirement: QuestRequirement) -> int:
	match requirement.quest_signal:
		QuestRequirement.QuestSignal.BUILDINGS_PLACED:
			if !buildings_placed.has(requirement.associated_building_name):
				buildings_placed[requirement.associated_building_name] = 0

			buildings_placed[requirement.associated_building_name] += 1
			return buildings_placed[requirement.associated_building_name]
			
		QuestRequirement.QuestSignal.NOTE_PLAYED:
			if !notes_played.has(requirement.associated_note_name):
				notes_played[requirement.associated_note_name] = 0

			notes_played[requirement.associated_note_name] += 1
			return notes_played[requirement.associated_note_name]
		
	return 0
