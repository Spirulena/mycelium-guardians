extends Button

class_name ModularMenuButton
@onready var buttonHighlight = $ButtonHighlight
@onready var buttonText = $MarginContainer/HBoxContainer/Label

@onready var animation: AnimationPlayer = get_tree().get_root().find_child("AnimationPlayer", true, false)

enum ButtonType {Continue, NewGame, Options, Help, Exit, Close, Background, ResetCamera, FollowUnit}
@export var button_type : ButtonType

enum CloseType {Options, HelpPopup, None}
@export var close_type : CloseType

@export var help_popup : MarginContainer
@export var options_menu : MarginContainer

const BUTTON_TEXTS = {
	ButtonType.Continue: "CONTINUE",
	ButtonType.NewGame:  "NEW GAME",
	ButtonType.Options:  "OPTIONS",
	ButtonType.Help:     "HELP",
	ButtonType.Exit:     "EXIT",
	ButtonType.Close:    "CLOSE",
	ButtonType.Background:     ""
}

func _ready():
	if button_type != ButtonType.Background:
		buttonHighlight.visible = false
		buttonText.add_theme_color_override("font_color", Color.BLACK)
		buttonText.text = BUTTON_TEXTS[button_type]

func _on_mouse_entered() -> void:
	if button_type != ButtonType.Background:
		buttonHighlight.visible = true
		buttonText.add_theme_color_override("font_color", Color.WHITE)

func _on_mouse_exited() -> void:
	if button_type != ButtonType.Background:
		buttonHighlight.visible = false
		buttonText.add_theme_color_override("font_color", Color.BLACK)

func _on_pressed() -> void:
	if button_type == ButtonType.Continue:
		print("Continue")
		
	elif button_type == ButtonType.NewGame:
		get_tree().change_scene_to_file("res://Alpha/Scenes/Game/Game.tscn")
		
	elif button_type == ButtonType.Options:
		if options_menu:
			animation.play("open_OptionsMenu")
			options_menu.visible = not options_menu.visible
		else:
			print("No options menu assigned on Options Button!")
		
	elif button_type == ButtonType.Help:
		if help_popup:
			animation.play("open_HelpPopup")
			help_popup.visible = not help_popup.visible
		else:
			print("No popup menu assigned on Help Button!")
		
	elif button_type == ButtonType.Exit:
		get_tree().quit()
		
	elif button_type == ButtonType.Background or button_type == ButtonType.Close:
		match close_type:
			CloseType.HelpPopup:
				if help_popup:
					animation.play("close_HelpPopup")
				else:
					print("No popup menu assigned on Background Button!")
			
			CloseType.Options:
				if options_menu:
					animation.play("close_OptionsMenu")
				else:
					print("No options menu assigned on Background Button!")
