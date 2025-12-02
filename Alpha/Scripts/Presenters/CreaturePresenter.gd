class_name CreaturePresenter
extends Node2D

# TODO: create function to differentiate object type
const TEXTURE_LOCATION = "res://Alpha/Sprites/Objects/creature.png" #placeholder sprite

var _sprite: Sprite2D

func _init():
	_sprite = Sprite2D.new()

func _ready():
	_load_sprite()

func _load_sprite():
	_sprite.texture = load(TEXTURE_LOCATION)
	add_child(_sprite)
