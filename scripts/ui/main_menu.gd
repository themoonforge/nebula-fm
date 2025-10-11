extends CanvasLayer

@onready var start_button: Button = %StartGameButton
@onready var options_open_button: Button = %OptionsOpenButton
@onready var credits_open_button: Button = %CreditsOpenButton
@onready var credits_close_button: Button = %CreditsCloseButton

@onready var credits_screen: CanvasLayer = %Credits
@onready var splash_screen: CanvasLayer = %SplashScreen

var is_blocked: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_print_startup_message()
	
	is_blocked = true
	splash_screen.splash_done.connect(_on_splash_done)
	
	start_button.pressed.connect(_on_start_button_pressed)
	start_button.mouse_entered.connect(_on_button_mouse_entered)
	options_open_button.pressed.connect(_on_options_open_button_pressed)
	options_open_button.mouse_entered.connect(_on_button_mouse_entered)
	credits_open_button.pressed.connect(_on_credits_open_button_pressed)
	credits_open_button.mouse_entered.connect(_on_button_mouse_entered)
	credits_close_button.pressed.connect(_on_credits_close_button_pressed)
	credits_close_button.mouse_entered.connect(_on_button_mouse_entered)
	
	credits_screen.hide()
	
func _on_splash_done() -> void:
	is_blocked = false
	
func _process(delta: float) -> void:
	if is_blocked:
		return
	
	if Input.is_action_just_pressed(&"ui_exit"):
		credits_screen.hide()

func _on_start_button_pressed() -> void:
	if is_blocked:
		return
	start_button.disabled = true
	MusicPlayer.play_sfx("ui_click_confirm")
	await MusicPlayer.sfx_player.finished
	SceneTransition.transition_scene("res://scenes/game.tscn")

func _on_button_mouse_entered() -> void:
	if is_blocked:
		return
		
	MusicPlayer.play_sfx("ui_click_tsk")

func _on_options_open_button_pressed() -> void:
	if is_blocked:
		return
		
	MusicPlayer.play_sfx("ui_click")
	OptionsMenu.show()
	
func _on_options_close_button_pressed() -> void:
	if is_blocked:
		return
		
	MusicPlayer.play_sfx("ui_click")
	OptionsMenu.hide()
	
func _on_credits_open_button_pressed() -> void:
	if is_blocked:
		return
		
	MusicPlayer.play_sfx("ui_click")
	credits_screen.show()
	
func _on_credits_close_button_pressed() -> void:
	if is_blocked:
		return
		
	MusicPlayer.play_sfx("ui_click")
	credits_screen.hide()

func _print_startup_message():
	print(r"""
	==================================================
	 _   _      _           _         ______ __  __ 
	| \ | |    | |         | |       |  ____|  \/  |
	|  \| | ___| |__  _   _| | __ _  | |__  | \  / |
	| . ` |/ _ \ '_ \| | | | |/ _` | |  __| | |\/| |
	| |\  |  __/ |_) | |_| | | (_| | | |    | |  | |
	|_| \_|\___|_.__/ \__,_|_|\__,_| |_|    |_|  |_|
	==================================================
	                                                 
	Thanks for playing Nebula FM! ‧₊˚♪ 𝄞₊˚⊹

	You might notice some debug prints here in the console,
	since the game is in active development.

	Game made by:  @iocutus, @bognari, @prodcautious, @pumpkinchariot
	→ Reach out on: https://pumpkinchariot.itch.io/nebula-fm
	
	✦ Created for Ludum Dare 58 ✦
	""")
