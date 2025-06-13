@tool
class_name NetworkMenuUIElement extends Panel

@onready var texture_button: TextureButton = %TextureButton
@onready var my_action: NetworkMenuAction

func setup(action: NetworkMenuAction):
	my_action = action
	texture_button.texture_normal = my_action.icon
	texture_button.tooltip_text = my_action.name
	texture_button.pressed.connect(on_pressed)

func on_pressed():
	my_action.handle_press()
	# what if blocked ?, ingore for now

	var t: Tween = self.create_tween()
	t.tween_property(texture_button, "scale", Vector2(1.1, 1.1), 0.05).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)
	t.tween_property(texture_button, "scale", Vector2(1, 1), 0.02)
