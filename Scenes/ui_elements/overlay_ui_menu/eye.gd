extends Node2D

# X eye behaviour
@onready var eye: Sprite2D = %eye
var original_position: Vector2
var max_distance: float = 5.0  # Max distance the sprite can move from its original position
var is_enabled: bool = true  # Controls whether the eye follows the mouse

func _ready() -> void:
	original_position = position  # Store the original position of the sprite

func _process(delta):
	if is_enabled:
		var mouse_position = get_global_mouse_position()
		var direction = (mouse_position - original_position).normalized()
		var distance = min(max_distance, original_position.distance_to(mouse_position))
		position = original_position + direction * distance

func toggle_following():
	is_enabled = !is_enabled
