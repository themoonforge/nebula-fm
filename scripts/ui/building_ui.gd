class_name BuildingUi extends Control

@onready var panel_container: Container = %PanelContainer
@onready var building_name: Label = %BuildingNameLabel
@onready var ui_components: Container = %UiComponents

var building: Building
var is_hovered: bool

func _ready() -> void:
	panel_container.mouse_entered.connect(_on_building_ui_mouse_entered)
	panel_container.mouse_exited.connect(_on_building_ui_mouse_exited)
	
func _set_up_components() -> void:
	for c in building.building_resource.ui_components:
		var instance = c.instantiate()
		if !instance.is_in_group(&"BuildingUiComponent"):
			instance.queue_free()
			continue
		
		if instance.has_method(&"set_up"):
			instance.set_up(building)
		
		if instance is PitchShifterComponent:
			instance.pitch_shifted.connect(_on_pitch_shifted)
		
		ui_components.add_child(instance)
	
func _process(delta: float) -> void:
	if !visible:
		return
		
	var local_mouse_pos = panel_container.get_local_mouse_position()
	var mouse_is_inside = panel_container.get_rect().has_point(local_mouse_pos)
	
	if is_hovered && !mouse_is_inside:
		print("mouse left area and was still visible - hide")
		is_hovered = false
		hide()
	elif !is_hovered && mouse_is_inside:
		is_hovered = true
	
func _on_pitch_shifted(new_pitch: int) -> void:
	print("new pitch received: ", new_pitch)
	if building.building_resource is PitcherBuildingResource:
		building.building_resource.pitch = new_pitch
	
func _on_building_ui_mouse_entered() -> void:
	print("entered")
	is_hovered = true
	
func _on_building_ui_mouse_exited() -> void:
	await get_tree().process_frame
	var local_mouse_pos = panel_container.get_local_mouse_position()
	if panel_container.get_rect().has_point(local_mouse_pos):
		is_hovered = true
	else:
		is_hovered = false
		hide()
		
func update() -> void:	
	for component in ui_components.get_children():
		if component.has_method(&"update"):
			component.update()

func setup(_building: Building) -> void:
	building = _building
	building_name.text = building.building_resource.name
	_set_up_components()
