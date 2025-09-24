extends Node2D

signal pressed
@onready var upgrade_button:TextureButton = %UpgradeButton
@onready var cost_panel = %cost_panel
@onready var info_panel = %info_panel
@onready var animation_player = $AnimationPlayer
@onready var upgrade_name = %upgrade_name

@export var upgrade_cost: Dictionary  = {
	ResourceObject.ResourceType.Water: 500,
	ResourceObject.ResourceType.Energy: 2000,
	ResourceObject.ResourceType.Minerals: 300,
	ResourceObject.ResourceType.Carbon: 500,
}
var upgraded: bool = false

func _ready():
	upgrade_button.mouse_entered.connect(_on_upgrade_button_mouse_entered)
	upgrade_button.mouse_exited.connect(_on_upgrade_button_mouse_exited)
	upgrade_button.pressed.connect(_on_upgrade_button_pressed)
	_init_visual_state()

func _init_visual_state():
	cost_panel.hide()
	info_panel.hide()
	upgrade_name.hide()

func _show_panels():
	animation_player.play("show")
	cost_panel.show()
	info_panel.show()
	upgrade_name.show()

func _hide_panels():
	cost_panel.hide()
	info_panel.hide()
	upgrade_name.hide()

func _on_upgrade_button_mouse_entered():
	# TODO_THIS: animate
	_show_panels()

func _on_upgrade_button_mouse_exited():
	_hide_panels()

func _on_upgrade_button_pressed():
	print_debug("upgrade requested")
	pressed.emit()


	animation_player.play("fly_off")

	var tween: Tween = create_tween()
	tween.tween_property(self, "global_position", global_position - Vector2(100, 2000), 0.7).set_trans(Tween.TRANS_CUBIC)
	#play sound FX
	upgraded = true
	# # add special case for smog absorber if upgraded. Or do it in upgrade
	# TODO: need a consume signal
