extends Node

@onready var sfx_player: AudioStreamPlayer2D = $SFXPlayer

var sfx_sounds = {
	"ui_click": preload("res://sfx/ui/ui_click.ogg"),
	"ui_click_pop": preload("res://sfx/ui/ui_click_pop.ogg"),
	"ui_click_tsk": preload("res://sfx/ui/ui_click_tsk.ogg"),
	"ui_click_confirm": preload("res://sfx/ui/ui_click_confirm.ogg"),
}

func play_sfx(sfx_name: String):
	sfx_player.stream = sfx_sounds[sfx_name]
	sfx_player.play()
