@tool
class_name TransformerItem extends Control

@export var transformer_resource: AbstractBuildingResource

@onready var placement_button: TextureButton = %PlacementButton
@onready var hover_name: Label = %HoverName

func _ready() -> void:
	placement_button.pressed.connect(_on_placement_button_pressed)
	placement_button.mouse_entered.connect(_on_transformer_item_mouse_entered)
	placement_button.mouse_exited.connect(_on_transformer_item_mouse_exited)
	
	placement_button.texture_normal = transformer_resource.hotbar_icon
	placement_button.texture_hover = transformer_resource.hotbar_icon_hovered
	placement_button.texture_pressed = transformer_resource.hotbar_icon_hovered

	hover_name.text = transformer_resource.name
	
	hover_name.hide()
	
	# sets the size of controler based on tecture sizes (needed because we use clip contents for the label)
	custom_minimum_size.x = transformer_resource.hotbar_icon.get_size().x
	
func _on_transformer_item_mouse_entered() -> void:
	EventBus.hotbar_hovered.emit(true)
	hover_name.show()
	MusicPlayer.play_sfx("ui_click_tsk")

func _on_transformer_item_mouse_exited() -> void:
	EventBus.hotbar_hovered.emit(false)
	hover_name.hide()
	
func _on_placement_button_pressed() -> void:
	print("clicked hotbar transformer")
	MapManager.set_active_transformer_ghost(transformer_resource)
	MusicPlayer.play_sfx("ui_click")
