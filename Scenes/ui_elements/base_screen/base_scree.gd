extends Control

@export var parent: Node

var trend_text: Dictionary = {
	1: "decreasing",
	0: "stable",
	-1: "increasing",
}

@onready var back_button: Button = %back_button

func _ready():
	back_button.pressed.connect(func(): parent.hide_colony_base_pressed())
