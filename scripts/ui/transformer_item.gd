class_name TransformerItem extends PanelContainer

@export var transformer_resource: TransformerResource

@onready var placement_button: Button = %PlacementButton
@onready var icon: TextureRect = %Icon
@onready var hover_name: Label = %HoverName

func _ready() -> void:
	placement_button.pressed.connect(_on_placement_button_pressed)
	placement_button.mouse_entered.connect(_on_transformer_item_mouse_entered)
	placement_button.mouse_exited.connect(_on_transformer_item_mouse_exited)
	
	icon.texture = transformer_resource.icon
	hover_name.text = transformer_resource.name
	
	hover_name.hide()
	
func _on_transformer_item_mouse_entered() -> void:
	hover_name.show()

func _on_transformer_item_mouse_exited() -> void:
	hover_name.hide()
	
func _on_placement_button_pressed() -> void:
	MapManager.set_active_transformer_ghost(transformer_resource)
