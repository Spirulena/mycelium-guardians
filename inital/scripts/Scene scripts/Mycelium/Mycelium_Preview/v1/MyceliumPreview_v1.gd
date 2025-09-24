extends Node2D

var coords: Vector2i
var default_modulate: Color ## #475e12
var healty_color: Color

@onready var sprite = $Sprite

func _ready():
	default_modulate = sprite.modulate
	healty_color = default_modulate
