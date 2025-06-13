extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation: Animation

var _model: BuildingObject
var _rand_speed_scale: float
var colors: Array = [
	'#b22d32', '#be4532', '#a28f44', '#92a441', '#7d955a', '#ac91d4', '#5a70a2', '#87271f', '#bb7dc1',
	'#a94021', '#7b9bcc', '#b19aa8', '#64862a', '#1b3b5c', '#804f57', '#b96c45', '#a98ad0', '#7d5243',
	'#6c1d33', '#7d5300', '#bf7c19', '#696a40', '#24be81', '#24ade2', '#5b6395', '#788c23', '#aaad1e',
	'#6a5200', '#748055', '#84221b', '#85b4a9', '#bfb4b9', '#9f69b8', '#b393de', '#99834a', '#756751',
	'#9aa4da', '#8187b5', '#bcb0b6', '#4f2c1e', '#772229', '#a94e58', '#7e8d31', '#ce8d78', '#632f55',
	'#ce6f14', '#a5a852', '#1d2d10'
]

@export var main_anim: AnimatedSprite2D

func _init():
	pass

func set_model(model: BuildingObject):
	_model = model

func _ready():
	#main_anim.modulate = colors.pick_random()
	# set color later
	_rand_speed_scale = randf_range(1.0, 1.0)
	animation_player.get_animation("cycle").resource_local_to_scene = true
	animation = animation_player.get_animation("cycle")

func set_color(new_color: Color):
	#var tween: Tween = get_tree().create_tween()
	#tween.tween_property(main_anim, "modulate", new_color, 1.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	main_anim.modulate = new_color

func set_random_color():
	# pass in the color
	main_anim.modulate = colors.pick_random()

func adjust_speed(factor: float):
	animation_player.speed_scale = _rand_speed_scale * factor

func start_cycle():
	animation_player.speed_scale = _rand_speed_scale
	animation_player.play("cycle")

func pause_cycle():
	animation.loop_mode = Animation.LOOP_NONE

func un_pause_cycle():
	animation.loop_mode = Animation.LOOP_LINEAR
	animation_player.play()

#func reveal(health):
	#var reveal_amount = health / 100.0
	#sprite.material.set("shader_parameter/reveal_amount", reveal_amount)
