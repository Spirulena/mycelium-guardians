extends Control

@export var small_circle : Sprite2D
@export var big_circle : Sprite2D

func _process(delta):
	big_circle.rotation += .2 * delta 
	small_circle.rotation += .3 * delta
