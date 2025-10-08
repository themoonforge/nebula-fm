extends CanvasLayer

func _ready() -> void:
	OptionsMenu.hide()
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("escape"):
		if OptionsMenu.visible:
			OptionsMenu.hide()
		else:
			OptionsMenu.show()
		
