class_name BuildingUiComponent extends Control

var building: Building

func _notification(what):
	if what == NOTIFICATION_SCENE_INSTANTIATED:
		add_to_group(&"BuildingUiComponent")

func _set_up(_building: Building) -> void:
	building = _building
