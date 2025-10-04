extends CanvasLayer

@onready var animation_player = $AnimationPlayer

func transition_scene(scene: String):
	get_tree().paused = true
	animation_player.play("screen_wipe")
	await animation_player.animation_finished
	get_tree().change_scene_to_file(scene)
	await get_tree().create_timer(1,true).timeout
	animation_player.play_backwards("screen_wipe")
	await animation_player.animation_finished
	get_tree().paused = false
