extends Node
class_name UIAnimations

@export var buttons : Array[Button]

@export var small_circle : Sprite2D
@export var big_circle : Sprite2D

@onready var animation_player: AnimationPlayer = get_tree().get_first_node_in_group("AnimationPlayer")

func _ready():
	if buttons.size() == 0:
		print("theres no buttons listed in the menu animations array!")
		pass

func _process(delta):
	update_button_scale()
	rotate_UI_Elements(delta)

func rotate_UI_Elements(delta):
	if small_circle == null or big_circle == null:
		return
	else:
		big_circle.rotation += .2 * delta 
		small_circle.rotation += .3 * delta

func close_help_popup():
	animation_player.play("close_HelpPopup")

func open_help_popup():
	animation_player.play("open_HelpPopup")

func close_options_menu():
	animation_player.play("close_OptionsMenu")

func open_options_menu():
	animation_player.play("open_OptionsMenu")

func update_button_scale():
	button_hover(1.1, 0.2) 

func tween_button(button: Button, property: String, amount, duration: float):
	var tween := create_tween()
	tween.tween_property(button, property, amount, duration)

func button_hover(tween_amount: float, duration: float):
	for button in buttons:
		if button:
			button.pivot_offset = button.size / 2
			if button.is_hovered():
				tween_button(button, "scale", Vector2.ONE * tween_amount, duration)
			else:
				tween_button(button, "scale", Vector2.ONE, duration)
