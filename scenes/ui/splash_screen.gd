extends CanvasLayer

signal splash_done()

@onready var splash_screen_texture: TextureRect = %SplashScreenTexture

func _ready() -> void:
	splash_screen_texture.modulate = Color.WHITE
	await get_tree().create_timer(1).timeout
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(splash_screen_texture, "modulate", Color.TRANSPARENT, 2.0)
	await tween.finished
	splash_done.emit()
