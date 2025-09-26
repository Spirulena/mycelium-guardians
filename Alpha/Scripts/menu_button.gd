extends Button

# create a main button scene /

# create button inheritants /

# create a button class
## each button can be refered to a different function accordings to its enum (Continue, NewGame, Options, Help, Button
## each button will have the same highlight and click feature /

class_name ModularButton
@onready var buttonHighlight = $ButtonHighlight
@onready var buttonText = $MarginContainer/HBoxContainer/Label

enum ButtonType {Continue, NewGame, Options, Help, Exit, Close}
@export var button_type : ButtonType

@export var help_popup : MarginContainer

const BUTTON_TEXTS = {
	ButtonType.Continue: "CONTINUE",
	ButtonType.NewGame:  "NEW GAME",
	ButtonType.Options:  "OPTIONS",
	ButtonType.Help:     "HELP",
	ButtonType.Exit:     "EXIT",
	ButtonType.Close:     ""
}

func _ready():
	if button_type != ButtonType.Close:
		buttonHighlight.visible = false
		buttonText.add_theme_color_override("font_color", Color.BLACK)
		buttonText.text = BUTTON_TEXTS[button_type]

func _on_mouse_entered() -> void:
	if button_type != ButtonType.Close:
		buttonHighlight.visible = true
		buttonText.add_theme_color_override("font_color", Color.WHITE)

func _on_mouse_exited() -> void:
	if button_type != ButtonType.Close:
		buttonHighlight.visible = false
		buttonText.add_theme_color_override("font_color", Color.BLACK)

func _on_pressed() -> void:
	if button_type == ButtonType.Continue:
		print("Continue")
		
	elif button_type == ButtonType.NewGame:
		print("NewGame")
		
	elif button_type == ButtonType.Options:
		print("Options")
		
	elif button_type == ButtonType.Help:
		if help_popup:
			help_popup.visible = not help_popup.visible
		else:
			print("No popup menu assigned on Help Button!")
		
	elif button_type == ButtonType.Exit:
		get_tree().quit()
		
	elif button_type == ButtonType.Close:
		if help_popup:
			help_popup.visible = not help_popup.visible
		else:
			print("No popup menu assigned on Background Button!")
