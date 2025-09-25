extends Button

# create a main button scene

# create button inheritants

# create a button class
## each button can be refered to a different function accordings to its sub class (Continue, NewGame, Options, Help, Button
## each button will have the same highlight and click feature

class_name ModularButton
@onready var buttonHighlight = $ButtonHighlight
@onready var buttonText = $MarginContainer/HBoxContainer/Label

enum ButtonType {Continue, NewGame, Options, Help, Exit}
@export var button_type : ButtonType

const BUTTON_TEXTS = {
	ButtonType.Continue: "CONTINUE",
	ButtonType.NewGame:  "NEW GAME",
	ButtonType.Options:  "OPTIONS",
	ButtonType.Help:     "HELP",
	ButtonType.Exit:     "EXIT"
}

func _ready():
	buttonHighlight.visible = false
	buttonText.add_theme_color_override("font_color", Color.BLACK)
	
	buttonText.text = BUTTON_TEXTS[button_type]

func _on_mouse_entered() -> void:
	buttonHighlight.visible = true
	buttonText.add_theme_color_override("font_color", Color.WHITE)

func _on_mouse_exited() -> void:
	buttonHighlight.visible = false
	buttonText.add_theme_color_override("font_color", Color.BLACK)
