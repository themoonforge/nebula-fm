extends Node

const TILE_SIZE: Vector2 = Vector2(16, 16)

@export var transformer_ghost_scene: PackedScene

var transformer_ghost_instance: TransformerGhost

func _ready() -> void:
	if !transformer_ghost_scene:
		return
		
	transformer_ghost_instance = transformer_ghost_scene.instantiate()
	transformer_ghost_instance.hide()
	add_child(transformer_ghost_instance)

func _process(delta: float) -> void:
	if !transformer_ghost_instance:
		return
		
	transformer_ghost_instance.global_position = get_viewport().get_mouse_position() - TILE_SIZE/2
	transformer_ghost_instance.global_position = transformer_ghost_instance.global_position.snapped(TILE_SIZE)
	
	if Input.is_action_just_pressed(&"ui_click"):
		var clicked_position: Vector2 = transformer_ghost_instance.global_position
		var clicked_cell: Vector2i = Vector2i(clicked_position.x / 16, clicked_position.y / 16)
		
		if GridManager.is_cell_free(clicked_cell):
			GridManager.set_cell(clicked_cell)
			place_transformer(transformer_ghost_instance, clicked_cell)
			#hide_ghost()

func place_transformer(transformer_ghost: TransformerGhost, cell: Vector2i) -> void:
	pass

func hide_ghost() -> void:
	if !transformer_ghost_instance:
		return
		
	transformer_ghost_instance.hide()

func set_active_transformer_ghost(transformer_resource: TransformerResource) -> void:
	if !transformer_ghost_instance:
		return
		
	transformer_ghost_instance.sprite.texture = transformer_resource.icon
	transformer_ghost_instance.sprite.modulate = Color(0.0, 0.894, 0.894, 0.541)
	transformer_ghost_instance.show()
