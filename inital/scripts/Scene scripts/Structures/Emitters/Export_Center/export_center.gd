extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation: Animation

func _ready():
	animation_player.get_animation("cycle").resource_local_to_scene = true
	animation = animation_player.get_animation("cycle")

func adjust_speed(factor: float):
	animation_player.speed_scale = 1.0 * factor

func start_cycle():
	animation_player.speed_scale = 1.0
	animation_player.play("cycle")

func pause_cycle():
	animation.loop_mode = Animation.LOOP_NONE

func un_pause_cycle():
	animation.loop_mode = Animation.LOOP_LINEAR
	animation_player.play()
