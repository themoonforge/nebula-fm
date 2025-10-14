extends Node

@export var c_texture: Texture
@export var d_texture: Texture
@export var e_texture: Texture
@export var f_texture: Texture
@export var g_texture: Texture
@export var a_texture: Texture
@export var b_texture: Texture
@export var package_texture: Texture

func get_texture_for_keys(key_numbers: Array[int]) -> Texture:
	if key_numbers.size() == 1:
		return get_texture_for_key(key_numbers[0])
	else:
		return NotePackageTextures.package_texture
		
	return null
	
func get_texture_for_key(key_number: int) -> Texture:
	match(key_number % 12):
		0, 1:
			return NotePackageTextures.c_texture
		2, 3:
			return NotePackageTextures.d_texture
		4:
			return NotePackageTextures.e_texture
		5, 6:
			return NotePackageTextures.f_texture
		7, 8:
			return NotePackageTextures.g_texture
		9, 10:
			return NotePackageTextures.a_texture
		11:
			return NotePackageTextures.b_texture
		
	return null
