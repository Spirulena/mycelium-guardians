class_name CreaturePresenter
extends Node2D

const TEXTURE_LOCATION = "res://Alpha/2D assets/TilesetTextures/Custom/creature.png"

var _sprite: Sprite2D

func _init():
	_sprite = Sprite2D.new()

func _ready():
	_load_sprite()

func _load_sprite():
	_sprite.texture = load(TEXTURE_LOCATION)
	add_child(_sprite)
