extends Node

var used_cells: Array[Vector2i]
	
func _on_mark_cell_occupied(cell: Vector2i) -> void:
	set_cell(cell)

func set_cell(cell: Vector2i) -> bool:
	if !is_cell_free(cell):
		return false
		
	used_cells.append(cell)
	
	return true

func free_cell(cell: Vector2i) -> bool:
	if is_cell_free(cell):
		return false
		
	var cell_idx: int = used_cells.find(cell)
	if cell_idx == -1:
		return false
	
	used_cells.remove_at(cell_idx)
	
	return true
	
func is_cell_free(cell: Vector2i) -> bool:
	if used_cells.has(cell):
		return false
	
	return true
