extends Node2D

var index: int
var coords: Vector2i
var green: bool = false
var radius = 2

@onready var area2d : Area2D = $"Area2D"

func _ready():
	modulate.a = 0.0
	var tween : Tween = self.create_tween()
	var c = Color(randf_range(0.8, 1.0), 1, 1)
	tween.tween_property(self, "modulate", Color(c, 1.0), randf_range(0.8,3.0))

	var rand_scale = randf_range(0.8, 1.0)
	scale = Vector2(rand_scale, rand_scale)
#	rotation_degrees = randf_range(-3,3)
	area2d.area_entered.connect(collided_with_smog)

func collided_with_smog(area):
	if area.has_method("die"):
		area.die()
