extends Control

@export var buttonHighlight : Sprite2D
@export var buttonText : Label

enum ButtonType {Continue, NewGame, Options, Help, Exit}
@export var button_type : ButtonType

@onready var ui_animations: UIAnimations = get_tree().get_first_node_in_group("UIAnimations")

const BUTTON_TEXTS = {
	ButtonType.Continue: "CONTINUE",
	ButtonType.NewGame:  "NEW GAME",
	ButtonType.Options:  "OPTIONS",
	ButtonType.Help:     "HELP",
	ButtonType.Exit:     "EXIT",
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

func _on_pressed() -> void:
	if button_type == ButtonType.Continue:
		print("Continue")
		
	if button_type == ButtonType.NewGame:
		get_tree().change_scene_to_file("res://Alpha/Scenes/Game/Game.tscn")
	
	if button_type == ButtonType.Options:
		ui_animations.open_options_menu()
	
	if button_type == ButtonType.Help:
		ui_animations.open_help_popup()
	
	if button_type == ButtonType.Exit:
		get_tree().quit()
