extends Node2D


@onready var grow_animation: AnimatedSprite2D = $"AnimatedSprite2D"

var building_enum = BuildingObject.StructureType.Techno_flat_panel
@onready var dissolve_animations = $dissolve_animations
# sfx
@onready var fume_hiss = $fume_hiss
@onready var panel_dies = $panel_dies

@export var dissolve_time: int = 3
signal release_acid_finished(coords)
var my_coords

func release_acid(coords):
	my_coords = coords
	dissolve_animations.play("dissolve_start")
	fume_hiss.play()

	var tween_delay = self.create_tween()
	tween_delay.tween_callback(panel_dies.play).set_delay(1.2)

	for i in dissolve_time:
		var tween: Tween = self.create_tween() ## instead of bind
		tween.tween_property(grow_animation, "modulate", Color(0.1, 0.1, 1.0, 0.9), 0.3).set_trans(Tween.TRANS_SINE)
		tween.tween_property(grow_animation, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.3).set_trans(Tween.TRANS_SINE)
		tween.tween_property(grow_animation, "modulate", Color(0.1, 0.1, 1.0, 0.9), 0.3).set_trans(Tween.TRANS_SINE)
		tween.tween_property(grow_animation, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.3).set_trans(Tween.TRANS_SINE)
		await tween.finished

# TODO: this should be dictated by model
# have funciton, start dissolve - dissolving
# end dissolve - dissolved
 
	dissolve_animations.play("dissolve_end")
	play_animation_in_reverse()
	await grow_animation.animation_finished
	var tween2 = self.create_tween()
	tween2.tween_property(grow_animation, "modulate", Color(1.0, 1.0, 1.0, 0.1), 0.5).set_trans(Tween.TRANS_SINE)
	tween2.tween_callback(grow_animation.queue_free)
	await tween2.finished
	release_acid_finished.emit(my_coords)
	queue_free()

func growing(model):
	pass

func idle():
	pass

func pruned():
	play_animation_in_reverse()
	await grow_animation.animation_finished
	queue_free()

func play_animation_in_reverse():
	grow_animation.speed_scale = 3.0
	grow_animation.play_backwards("default")
