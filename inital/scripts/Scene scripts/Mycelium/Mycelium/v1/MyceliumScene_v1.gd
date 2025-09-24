extends Node2D

var coords: Vector2i
var default_modulate: Color ## #475e12
var healty_color: Color
@onready var round_back: AnimatedSprite2D = $"round_back"
@onready var round_front: AnimatedSprite2D = $"round_front"
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var animations: Array[SpriteFrames]
# the whole collor changes would do better in component, as it is duplicated all over the place
@onready var animation_player = $AnimationPlayer


## TODO_DEMO: Need to warp it up in some general Mycelium Container as it is hard to fin
# also delete previous versions

# TODO: pass the model. Read the state, health and update
func _ready():
	default_modulate = animated_sprite.modulate
	healty_color = default_modulate
	animated_sprite.sprite_frames = animations.pick_random()
	var frame_count = animated_sprite.sprite_frames.get_frame_count("default")
	animated_sprite.frame = 0

	# outline
	round_back.frame = 59
	round_back.play_backwards("default")
	round_back.animation_finished.connect(_on_animation_finished_cleanup.bind(round_back))
	round_front.frame = 59
	round_front.play_backwards("default")
	round_front.animation_finished.connect(_on_animation_finished_cleanup.bind(round_front))

func growing(model):
	var health = model.get_health()
	var frame_count = animated_sprite.sprite_frames.get_frame_count("default")
	var curr_frame = int(frame_count * (health / 100))
	animated_sprite.frame = curr_frame
	#animated_sprite.play("default")
	if health > 1:
		animation_player.stop()
	else:
		if not animation_player.is_playing():
			animation_player.play("Queued") #

func idle():
	var frame_count = animated_sprite.sprite_frames.get_frame_count("default")
	animated_sprite.frame = frame_count - 1
	animation_player.stop()
	#print_debug(animation_player.is_playing())
	
func pruned():
	var tween = self.create_tween()
	tween.tween_property(animated_sprite, "modulate", Color(0.1, 0.1, 0.1, 0.8), 0.3).set_trans(Tween.TRANS_SINE)
	tween.tween_property(animated_sprite, "modulate", Color(1.0, 0.3, 0.3, 0.8), 0.2).set_trans(Tween.TRANS_SINE)
	tween.set_loops(5)
	animated_sprite.play_backwards("default")
	await animated_sprite.animation_finished
	queue_free()

func _on_animation_finished_cleanup(object):
	object.queue_free()
