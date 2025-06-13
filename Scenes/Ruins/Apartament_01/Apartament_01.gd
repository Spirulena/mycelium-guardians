extends Node2D

# TODO_DEMO: when selected and decomposing
# For apartament building, play hotel lounge music, and some human noises, voices, loughs
# silent after gone, or keep quiter then decomposing more, or more distorted ?

@onready var cover = $cover
@onready var animation_player = $AnimationPlayer


func play_cover():
	cover.sprite_frames = Loader.get_loader().return_scene("ruin_apartament_mycelium_frames_short")
	animation_player.play("RESET")
	# Animate the mycelium grow over history object
	animation_player.play("cover")

func _play_cover_animation_sprites():
	cover.play("default")
	cover.animation_finished.connect(decompose_loop)

func decompose_loop():
	animation_player.play("decompose")

func pause_decomposition():
	animation_player.pause()

func decomposition_finished():
	# Animate fade out
	animation_player.play("fade_out")
