extends Node

const TILE_SIZE: Vector2 = Vector2(16, 16)
const COLOR_FREE: Color = Color(0.0, 0.894, 0.894, 0.541)
const COLOR_OCCUPIED: Color = Color(1.0, 0.68, 0.744, 0.541)

@export var transformer_ghost_scene: PackedScene

@onready var placed_transformers_container: Node2D = %PlacedTransformersContainer

var transformer_ghost_instance: TransformerGhost
var transformer_ghost_active: bool
var placed_transformers: Dictionary[Vector2i, Transformer]

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
	transformer_ghost_instance.sprite.modulate = COLOR_FREE
	
	var hovered_position: Vector2 = transformer_ghost_instance.global_position
	var hovered_cell: Vector2i = Vector2i(hovered_position.x / 16, hovered_position.y / 16)
	
	if Input.is_action_just_pressed(&"ui_right_click"):
		remove_transformer(hovered_cell)
	
	if !transformer_ghost_active:
		return
	
	if !GridManager.is_cell_free(hovered_cell):
		transformer_ghost_instance.sprite.modulate = COLOR_OCCUPIED
		return
	
	if Input.is_action_just_pressed(&"ui_click"):
		var clicked_position: Vector2 = transformer_ghost_instance.global_position
		var clicked_cell: Vector2i = Vector2i(clicked_position.x / 16, clicked_position.y / 16)
		
		if GridManager.is_cell_free(clicked_cell):
			GridManager.set_cell(clicked_cell)
			place_transformer(transformer_ghost_instance, clicked_cell)
			#hide_ghost()
			
func remove_transformer(cell: Vector2i) -> void:
	if GridManager.is_cell_free(cell):
		return
		
	if !placed_transformers.has(cell):
		return
		
	var transformer: Transformer = placed_transformers[cell]
	transformer.queue_free()
	
	GridManager.free_cell(cell)

func place_transformer(transformer_ghost: TransformerGhost, cell: Vector2i) -> void:
	if !transformer_ghost_instance:
		return
		
	var transformer_instance: Transformer = transformer_ghost_instance.transformer_scene.instantiate()
	transformer_instance.global_position = Vector2(cell.x, cell.y) * TILE_SIZE
	placed_transformers_container.add_child(transformer_instance)
	placed_transformers[cell] = transformer_instance

func hide_ghost() -> void:
	if !transformer_ghost_instance:
		return
	
	transformer_ghost_active = false
	transformer_ghost_instance.hide()

func set_active_transformer_ghost(transformer_resource: TransformerResource) -> void:
	if !transformer_ghost_instance:
		return
		
	transformer_ghost_active = true
	
	transformer_ghost_instance.transformer_scene = transformer_resource.scene
	transformer_ghost_instance.sprite.texture = transformer_resource.icon
	transformer_ghost_instance.sprite.modulate = COLOR_FREE
	transformer_ghost_instance.show()
