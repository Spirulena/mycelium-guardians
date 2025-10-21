extends Button

class_name ModularOptionsButton
@onready var buttonNormal = $ButtonHighlight
@onready var buttonHighlight = $ButtonHighlited
@onready var buttonPressed = $ButtonPressed

@onready var settingsIcon = $SettingsIcon
@onready var volumeIcon = $VolumeIcon
@onready var graphicsIcon = $GraphicsIcon
@onready var pcIcon = $pcIcon
@onready var controllerIcon = $ControllerIcon
@onready var resetCameraIcon = $ResetCameraIcon
@onready var followCameraIcon = $FollowCameraIcon

enum ButtonType {Options, Volume, Graphics, PC, Controller, ResetCamera, FollowCamera,}
@export var button_type : ButtonType

var BUTTON_ICONS = {} 

var camera

func _ready():
	camera = get_tree().get_first_node_in_group("Camera")
	
	buttonNormal.visible = true
	buttonHighlight.visible = false
	buttonPressed.visible = false
	
	BUTTON_ICONS = {
		ButtonType.Options: settingsIcon,
		ButtonType.Volume:  volumeIcon,
		ButtonType.Graphics: graphicsIcon,
		ButtonType.PC: pcIcon,
		ButtonType.Controller: controllerIcon,
		ButtonType.ResetCamera: resetCameraIcon,
		ButtonType.FollowCamera: followCameraIcon
	}

	var icon = BUTTON_ICONS[button_type]
	_set_icon(icon)

func _on_mouse_entered() -> void:
	buttonNormal.visible = false
	buttonHighlight.visible = true
	buttonPressed.visible = false

func _on_mouse_exited() -> void:
	buttonNormal.visible = true
	buttonHighlight.visible = false
	buttonPressed.visible = false

func _on_pressed() -> void:
	buttonNormal.visible = false
	buttonHighlight.visible = false
	buttonPressed.visible = true
	
	if button_type == ButtonType.ResetCamera:
		camera.resetCamera()
		
	if button_type == ButtonType.FollowCamera:
		camera.followUnit()

func _set_icon(icon: Node) -> void:
	settingsIcon.visible = false
	volumeIcon.visible = false
	graphicsIcon.visible = false
	pcIcon.visible = false
	controllerIcon.visible = false

	icon.visible = true
