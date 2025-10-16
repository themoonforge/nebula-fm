extends CanvasLayer

@export var quest_resources: Array[QuestResource]
@export var quest_info_scene: PackedScene
@onready var quest_info_container: Container = %QuestInfoContainer
@onready var tutorial_panel: Container = %TutorialPanel
@onready var show_tutorial_button: Button = %ShowTutorialButton

var buildings_placed: Dictionary[StringName, int]
var notes_played: Dictionary[StringName, int]
var notes_transmitted: Dictionary[StringName, int]
var played_songs: Array[StringName]

var button_style_normal: StyleBoxFlat
var button_style_hover: StyleBoxFlat

var is_hovering_button: bool

var is_in_tutorial: bool = true

func _ready() -> void:
	MapManager.regenerate.connect(_on_map_regenerate)
	QuestTracker.quest_completed.connect(_on_quest_complete)
	
	tutorial_panel.hide()
	
	button_style_normal = show_tutorial_button.get_theme_stylebox("normal")
	button_style_hover = show_tutorial_button.get_theme_stylebox("hover")
	
	show_tutorial_button.mouse_entered.connect(_on_show_tutorial_button_mouse_entered)
	show_tutorial_button.mouse_exited.connect(_on_show_tutorial_button_mouse_exited)
	tutorial_panel.mouse_entered.connect(_on_tutorial_panel_mouse_entered)
	tutorial_panel.mouse_exited.connect(_on_tutorial_panel_mouse_exited)
	
	MusicPlayer.current_played_song.connect(_on_play_song)
	EventBus.note_played.connect(_on_note_played)
	EventBus.note_transmitted.connect(_on_note_transmitted)
	MapManager.place_building.connect(_on_placed_building)
	_render_quest_info_items()
	
func _on_map_regenerate() -> void:
	buildings_placed = {}
	notes_played = {}
	notes_transmitted = {}
	
	for resource in quest_resources:
		resource.complete = false
		for requirement in resource.completed_requirements:
			requirement.complete = false
	
func _on_quest_complete(quest_resource: QuestResource) -> void:
	for quest in quest_resources:
		if quest.is_tutorial and !quest.complete:
			return
	if is_in_tutorial:
		is_in_tutorial = false
		MusicPlayer.loop_finished.emit(null)
	
func _on_note_played(note_resource: MidiInputNoteResource) -> void:
	var simple = note_resource.simple_name_flat_up
	if notes_played.has(simple):
		notes_played[simple] = notes_played[simple] + 1
	else:
		notes_played[simple] = 1
	check_quest_completion(QuestRequirement.QuestSignal.NOTE_PLAYED)

func _on_note_transmitted(note_resource: MidiInputNoteResource) -> void:
	var simple = note_resource.simple_name_flat_up
	if notes_transmitted.has(simple):
		notes_transmitted[simple] = notes_transmitted[simple] + 1
	else:
		notes_transmitted[simple] = 1
	check_quest_completion(QuestRequirement.QuestSignal.NOTE_TRANSMITTED)

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

func _on_play_song(song_key: String):
	played_songs.append(song_key)
	check_quest_completion(QuestRequirement.QuestSignal.RADIO_SONGS_FINISHED)


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
			
			if requirement.quest_signal == quest_signal && requirement.amount <= mapped_required_amount:
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
			return notes_played[requirement.associated_note_name]
		QuestRequirement.QuestSignal.NOTE_TRANSMITTED:
			return notes_transmitted[requirement.associated_note_name]
		QuestRequirement.QuestSignal.RADIO_SONGS_FINISHED:
			var index = played_songs.find(requirement.associated_song_name)
			if index > -1:
				return 1
			return 0
	return 0
