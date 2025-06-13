extends Button

@onready var display = DisplayServer
var is_fullscreen = false


func _on_Fullscreen_pressed():
	if display.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		display.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		is_fullscreen = false
	else:
		display.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		is_fullscreen = true

	if is_fullscreen:
		text = "Window Mode" 
	else:
		text = "Fullscreen"

func _ready():
	pressed.connect(_on_Fullscreen_pressed)
