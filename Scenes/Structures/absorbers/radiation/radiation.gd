extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation: Animation

var _model: BuildingObject

@export var sprite: Sprite2D

var colors_l: Array = [
	'#b22d32', '#be4532', '#a28f44', '#92a441', '#7d955a', '#ac91d4', '#5a70a2', '#87271f', '#bb7dc1',
	'#a94021', '#7b9bcc', '#b19aa8', '#64862a', '#1b3b5c', '#804f57', '#b96c45', '#a98ad0', '#7d5243',
	'#6c1d33', '#7d5300', '#bf7c19', '#696a40', '#24be81', '#24ade2', '#5b6395', '#788c23', '#aaad1e',
	'#6a5200', '#748055', '#84221b', '#85b4a9', '#bfb4b9', '#9f69b8', '#b393de', '#99834a', '#756751',
	'#9aa4da', '#8187b5', '#bcb0b6', '#4f2c1e', '#772229', '#a94e58', '#7e8d31', '#ce8d78', '#632f55',
	'#ce6f14', '#a5a852', '#1d2d10'
]
@export var colors: Array = []
@export var palette_img: Texture2D

func _ready():
	#load_palette()
	sprite.modulate = colors_l.pick_random()
	animation_player.get_animation("cycle").resource_local_to_scene = true
	animation = animation_player.get_animation("cycle")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed('cycle_color'):
		var tmp = colors.pop_back()
		colors.push_front(tmp)
		sprite.modulate = tmp
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

func load_palette():
	# Load the image
	#var img = Image.new()
	#img.load("res://path_to_your_palette_image.png")
	# Ensure the image is valid
	#if img.empty():
		#print("Failed to load image")
		#return
	var img: Image = palette_img.get_image()

	# Get width of the image
	var width:int = img.get_width()

	# Scan only across the x-axis (top row)
	for x in range(width):
		var color = img.get_pixel(x, 0)  # Only scan the top row (y = 0)
		if !colors.has(color):  # Avoid duplicate colors
			colors.append(color)

	# Test: Print a random color
	if colors.size() > 0:
		var random_color = colors.pick_random()
		print("Random Color: ", random_color)
