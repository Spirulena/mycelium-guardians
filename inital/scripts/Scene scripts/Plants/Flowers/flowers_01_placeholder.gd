extends Node2D

var coords: Vector2i
var radius = 1
#@export var companion_animal: Array[PackedScene] = [preload("res://Animals/Placeholders/Moths/moths_01.tscn")]
#@onready var companion_animal_instance = companion_animal.pick_random().instantiate()

func _ready():
	# random sprite
	$sprites.get_children().pick_random().visible = true
	# alpha
	modulate.a = 0.0
	var tween : Tween = self.create_tween()
	var c = Color(randf_range(0.8, 1.0), 1, 1)
	tween.tween_property(self, "modulate", Color(c, 1.0), randf_range(0.8,3.0))
	# rand scale
	var rand_scale = randf_range(0.9, 1)
	scale = Vector2(rand_scale, rand_scale)

	# add animal
#	get_tree().get_first_node_in_group("Moths").add_child(companion_animal_instance)
	#add_child(companion_animal_instance)


func fade_out():
	var tween : Tween = self.create_tween()
	tween.tween_property(self, "modulate", Color.TRANSPARENT, randf_range(0.8,3.0))
	await tween.finished
	queue_free()
