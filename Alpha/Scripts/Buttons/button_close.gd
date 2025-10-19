extends Control

@export var buttonHighlight : Sprite2D
@export var buttonText : Label

enum CloseType {CloseOptions, CloseHelpPopup, Background}
@export var close_type : CloseType

enum BackgroundType {CloseHelpPopup, CloseOptions, None}
@export var background_type : BackgroundType

@onready var ui_animations: UIAnimations = get_tree().get_first_node_in_group("UIAnimations")

func _ready():
	if close_type != CloseType.Background:
		buttonHighlight.visible = false
		buttonText.modulate = Color.BLACK
		buttonText.text = "CLOSE"

func _on_mouse_entered() -> void:
	if close_type != CloseType.Background:
		buttonHighlight.visible = true
		buttonText.modulate = Color.WHITE

func _on_mouse_exited() -> void:
	if close_type != CloseType.Background:
		buttonHighlight.visible = false
		buttonText.modulate = Color.BLACK

func _on_pressed() -> void:	
	if close_type == CloseType.CloseHelpPopup:
		ui_animations.close_help_popup()
	
	if close_type == CloseType.CloseOptions:
		ui_animations.close_options_menu()
	
	if background_type == BackgroundType.None:
		return
	elif background_type == BackgroundType.CloseOptions:
		ui_animations.close_options_menu()

	if background_type == BackgroundType.None:
		return
	elif background_type == BackgroundType.CloseHelpPopup:
		ui_animations.close_help_popup()
