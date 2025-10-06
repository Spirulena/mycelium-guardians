extends Control

@export var small_circle : Sprite2D
@export var big_circle : Sprite2D

@export var buttons : Array[Button]

func _ready():
	if buttons.size() == 0:
		print("theres no buttons listed in the menu animations array!")

func _process(delta):
	big_circle.rotation += .2 * delta 
	small_circle.rotation += .3 * delta
	
	update_button_scale()

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
