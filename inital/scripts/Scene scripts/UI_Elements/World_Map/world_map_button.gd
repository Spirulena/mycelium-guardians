extends Button

@export var parent: Node

func _ready():
	pressed.connect(_on_button_pressed)

func _on_button_pressed():
	parent.show_world_map_pressed()
