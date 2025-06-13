class_name OldButtomButtons_Button extends TextureButton

# Called when the node enters the scene tree for the first time.
@export var menu: OldButtomButtons
@export var button_type: String

# TODO: Investigate why it doesn't show up correct the first time in the editor
@export var keyboard_shortcut: String:
	get:
		return keyboard_shortcut
	set(value):
		if button != null:
			button.text = value
		keyboard_shortcut = value

@onready var button = $Button
@onready var sprite_2d = $Sprite2D

func _ready():
	sprite_2d.modulate = Color.TRANSPARENT
	button.text = keyboard_shortcut

	pressed.connect(_on_button_pressed)
	menu.register_button(self)

## Handle change in buttom menu
func action_changed(prev, current):
	var new_color: Color = Color.TRANSPARENT
	if current == button_type:
		new_color = Color.WHITE

	var tween: Tween = create_tween()
	tween.tween_property(sprite_2d, "modulate", new_color, 0.2).set_trans(Tween.TRANS_CUBIC)

func _on_button_pressed():
	#Events.play_sfx_type.emit(SfxPlayer.SFX.bottom_menu_button_pressed)
	menu.button_pressed(button_type)
