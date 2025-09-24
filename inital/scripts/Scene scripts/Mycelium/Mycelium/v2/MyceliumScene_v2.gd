extends Node2D

# 93a852
var modulate_color: Color = Color('93a852')
var coords: Vector2i
var default_modulate: Color ## #475e12
var healty_color: Color

@onready var animated_sprite_top_bottom: AnimatedSprite2D = $modulate/AnimatedSprite2D_top_bottom
@onready var animated_sprite_bottom_top = $modulate/AnimatedSprite2D_bottom_top
@onready var animated_sprite_left_right = $modulate/AnimatedSprite2D_left_right
@onready var animated_sprite_right_left = $modulate/AnimatedSprite2D_right_left



@onready var animated_sprite_center = $modulate/AnimatedSprite2D_center

@export var animations: Array[SpriteFrames]
# the whole collor changes would do better in component, as it is duplicated all over the place
@onready var animation_player = $AnimationPlayer
@onready var animation_player_ground = $AnimationPlayer_ground
@onready var sprites_modulate = $modulate
@export var modulate_with_green: bool = false

## TODO_DEMO: Need to warp it up in some general Mycelium Container as it is hard to fin
# also delete previous versions

var _model:MyceliumObject

func set_model(model):
	_model = model

func _ready():
	default_modulate = $modulate.modulate
	healty_color = default_modulate
	
	if modulate_with_green:
		sprites_modulate.modulate = modulate_color

	var frame_count = animated_sprite_top_bottom.sprite_frames.get_frame_count("default")
	animated_sprite_top_bottom.frame = 0
	animated_sprite_bottom_top.frame = 0
	animated_sprite_left_right.frame = 0
	animated_sprite_right_left.frame = 0

	animated_sprite_center.sprite_frames = animations.pick_random()
	animated_sprite_center.frame = 0

func grow_sfx():
	$AudioStreamPlayer2D.play()

func growing():
	animation_player.stop()
	var health = _model.get_health()
	var frame_count = animated_sprite_top_bottom.sprite_frames.get_frame_count("default")
	var curr_frame = int(frame_count * (health / 100))

	# Now which one should play. top_bottom, bottom_top or both
	var level_controller = LevelController.get_level_controller()
	# or set flags and animate based on that
	if level_controller.have_neighbor_to(_model.get_coords(), Vector2i.UP):
		animated_sprite_top_bottom.frame = curr_frame
	if level_controller.have_neighbor_to(_model.get_coords(), Vector2i.DOWN):
		animated_sprite_bottom_top.frame = curr_frame
	if level_controller.have_neighbor_to(_model.get_coords(), Vector2i.LEFT):
		animated_sprite_left_right.frame = curr_frame
	if level_controller.have_neighbor_to(_model.get_coords(), Vector2i.RIGHT):
		animated_sprite_right_left.frame = curr_frame

func queue():
	# Outline for queued
	if not animation_player.is_playing():
		animation_player.play("Queued")

func idle():
	var frame_count = animated_sprite_top_bottom.sprite_frames.get_frame_count("default")
	var last_frame = frame_count - 1
	# Set based on neighbours.
	var level_controller = LevelController.get_level_controller()
	# or set flags and animate based on that
	if level_controller.have_neighbor_to(_model.get_coords(), Vector2i.UP):
		animated_sprite_top_bottom.frame = last_frame
	if level_controller.have_neighbor_to(_model.get_coords(), Vector2i.DOWN):
		animated_sprite_bottom_top.frame = last_frame
	if level_controller.have_neighbor_to(_model.get_coords(), Vector2i.LEFT):
		animated_sprite_left_right.frame = last_frame
	if level_controller.have_neighbor_to(_model.get_coords(), Vector2i.RIGHT):
		animated_sprite_right_left.frame = last_frame

	animation_player.stop()
	animated_sprite_center.play("default")
	animation_player_ground.play("Purify")
	#animated_sprite_center.animation_finished.connect(func(): animation_player_ground.play("Purify"))

func pruned():
	var tween = self.create_tween()
	tween.tween_property($modulate, "modulate", Color(0.1, 0.1, 0.1, 0.8), 0.3).set_trans(Tween.TRANS_SINE)
	tween.tween_property($modulate, "modulate", Color(1.0, 0.3, 0.3, 0.8), 0.2).set_trans(Tween.TRANS_SINE)
	tween.set_loops(5)
	animated_sprite_top_bottom.play_backwards("default")
	await animated_sprite_top_bottom.animation_finished
	queue_free()

func _on_animation_finished_cleanup(object):
	object.queue_free()

func _process(delta):
	growing()
