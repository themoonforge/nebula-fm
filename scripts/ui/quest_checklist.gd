extends CanvasLayer

@export var quest_resources: Array[QuestResource]
@export var quest_info_scene: PackedScene
@onready var quest_info_container: Container = %QuestInfoContainer
@onready var tutorial_panel: Container = %TutorialPanel
@onready var show_tutorial_button: Button = %ShowTutorialButton

var buildings_placed: Dictionary[String, int]

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
	
	MapManager.place_building.connect(_on_placed_building)
	_render_quest_info_items()
	
func _on_quest_complete(quest_resource: QuestResource) -> void:
	var button_font_color = show_tutorial_button.get_theme_color("font_color")

	var tween1 = create_tween()
	tween1.set_ease(Tween.EASE_IN_OUT)
	var darken_parallel = tween1.parallel()
	darken_parallel.tween_property(show_tutorial_button, "modulate", Color(0.192, 0.161, 0.282, 1.0), 0.25)
	darken_parallel.tween_method(_set_button_font_color, button_font_color, Color(0.9, 0.85, 0.75, 1.0), 0.25)

	await tween1.finished

	var tween2 = create_tween()
	tween2.set_ease(Tween.EASE_IN_OUT)
	var lighten_parallel = tween2.parallel()
	lighten_parallel.tween_property(show_tutorial_button, "modulate", Color.WHITE, 1.0)
	lighten_parallel.tween_method(_set_button_font_color, Color(0.9, 0.85, 0.75, 1.0), button_font_color, 1.0)


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
			
			print(buildings_placed)
			
			return buildings_placed[requirement.associated_building_name]
		
	return 0
