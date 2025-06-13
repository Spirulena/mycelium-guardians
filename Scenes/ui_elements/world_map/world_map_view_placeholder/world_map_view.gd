extends Control

@export var parent: Node

@onready var back_to_surface = %back_to_surface

func _ready():
	back_to_surface.pressed.connect(func(): parent.close_world_map_pressed())
