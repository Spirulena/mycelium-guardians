extends Node2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func exit_tutorial() -> void:
	Global.main.exit_tutorial(3)
