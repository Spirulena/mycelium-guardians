extends Node2D

@onready var animated_sprite: AnimatedSprite2D = $"AnimatedSprite2D"
var coords: Vector2i

var radius = 0 ## that is for smog and radiation absorbtion
# probably should have separate for each, or even better store in resource for the type

# could connect to smog changed just for this tile
# for now check once 2 sec to tween to less green on smog

func _ready():

	randomize()

	animated_sprite.frame = randi_range(0, animated_sprite.sprite_frames.get_frame_count("default")-1)
	animated_sprite.speed_scale = randf_range(1, 1.4)

	modulate.a = 0.0
	var tween : Tween = self.create_tween()

	#var c = Color(randf_range(0.54, 1.0), 0.71875, 0.2460)
	var c = Color(1.0, 0.71875, 0.2460)
	tween.tween_property(self, "modulate", Color(c, 1.0), randf_range(0.8,3.0))

	var rand_scale = randf_range(0.8, 1.0)
	scale = Vector2(rand_scale, rand_scale)

func fade_out():
	var tween : Tween = self.create_tween()
	tween.tween_property(self, "modulate", Color.TRANSPARENT, randf_range(0.8,3.0))
	await tween.finished
	queue_free()

#func set_grass_shader(smog_level):
	## Assuming smog_level ranges from 1 (no smog) to 10 (maximum smog)
	## Adjust the red component based on smog level
	#var red = lerp(0.54, 1.0, (smog_level - 1) / 9)
#
	## Create the color with the adjusted red component
	#var c = Color(red, 0.71875, 0.2460, 1.0)  # Added alpha of 1.0 for completeness
	#if is_equal_approx(modulate.r, c.r):
		#return
	## Use tween to smoothly transition to the new color
	#var tween : Tween = self.create_tween()
	#tween.tween_property(self, "modulate", c, 1.9).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)

func set_grass_shader(smog_level):
	# No smog (0) to maximum smog (10), increasing red component
	# Assuming original greenish color at smog level 0 and getting redder as smog increases
	var red = lerp(0.54, 1.0, smog_level / 4.0)

	# Keep the original green and blue components of the texture color
	var green = modulate.g  # Keep original green
	var blue = modulate.b  # Keep original blue

	# Create the color with the adjusted red component, and original green and blue
	var new_color = Color(red, green, blue, 1.0)  # Add alpha of 1.0 for completeness

	# Check if a significant color change is required to minimize unnecessary tweening
	if not is_equal_approx(modulate.r, new_color.r):
		# Use tween to smoothly transition to the new color
		var tween: Tween = self.create_tween()
		tween.tween_property(self, "modulate", new_color, 1.9).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)

#func set_grass_shader(smog_level):
	## Correct the range for smog_level starting from 0
	#var red = lerp(0.54, 1.0, smog_level / 10.0)  # This remains correct for red's increase
#
	## For green component, start with a healthy green value at no smog and decrease it as smog increases
	#var green = lerp(0.71875, 0.5, smog_level / 10.0)  # Adjust the second parameter to control how much green decreases
#
	## Keeping the blue component constant as you haven't mentioned changing it
	#var blue = 0.2460
#
	## Create the color with the adjusted components
	#var c = Color(red, green, blue, 1.0)  # Added alpha of 1.0 for completeness
#
	## Only create a new tween if the current modulate color significantly differs from the target
	#if not is_equal_approx(modulate.r, c.r) or not is_equal_approx(modulate.g, c.g):
		## Use tween to smoothly transition to the new color
		#var tween: Tween = self.create_tween()
		#tween.tween_property(self, "modulate", c, 1.9).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)
