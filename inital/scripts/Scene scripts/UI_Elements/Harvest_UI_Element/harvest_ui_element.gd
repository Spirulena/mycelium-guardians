extends Node2D

var coords
var type

@onready var _button: TextureButton = %TextureButton

signal clicked(instance, coords)

func set_controller(controller):
	self.controller = controller

func _ready():
	_button.pressed.connect(_on_button_pressed)

func animate():
	var tween: Tween = self.create_tween()
	tween.tween_property(self, "modulate", ResourceObject.get_resource_type_color(type), 0.3)
	show()

func harvesting():
	%ExplosiveCircles.restart()
	await %ExplosiveCircles.finished
	var tween: Tween = self.create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(queue_free)

func remove():
	queue_free()

func _on_button_pressed():
	clicked.emit(self, coords)
