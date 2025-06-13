extends Node2D

@onready var sprite = $sprites/Legg01

func _init():
	pass

func _ready():
	pass

func reveal(health):
	var reveal_amount = health / 100.0
	sprite.material.set("shader_parameter/reveal_amount", reveal_amount)
