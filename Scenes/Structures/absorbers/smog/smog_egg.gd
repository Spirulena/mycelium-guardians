extends Node2D

@onready var sprite = $sprites/Legg01
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var vfx_smog_suck = $VFX_Smog_Suck
var _model: BuildingObject

func _init():
	pass

func set_model(model: BuildingObject):
	_model = model

func _ready():
	pass

func reveal(health):
	var reveal_amount = health / 100.0
	sprite.material.set("shader_parameter/reveal_amount", reveal_amount)

func start_cycle():
	animation_player.speed_scale = randf_range(0.5, 1.2)
	animation_player.play("cycle")
	animation_player.animation_changed.connect(func(old, new):
		animation_player.speed_scale = randf_range(0.5, 1.2)
		)
	animation_player.animation_finished.connect(func(anim_name):
		animation_player.play("cycle")
		)
	#vfx_smog_suck.emitting = true
	vfx_smog_suck.restart()

func pause_cycle():
	animation_player.pause()

func un_pause_cycle():
	animation_player.play()

func emit_egg_chance():
	LevelController.get_level_controller().model_changed.emit({
		'type': 'SmogAbsorberCycle',
		'coords': _model.get_coords(),
		'prev': null,
		'curr': _model,
		'action': 'cycle_finished',
	})
