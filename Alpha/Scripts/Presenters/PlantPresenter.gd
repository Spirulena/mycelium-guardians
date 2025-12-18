class_name PlantPresenter
extends Node2D

# TODO: create function to differentiate object type
const TEXTURE_LOCATION = "res://Alpha/Sprites/Objects/Plant.png" #placeholder sprite

var _sprite: Sprite2D

func _init(object: PlantObject):
	_sprite = Sprite2D.new()
	object.state_changed.connect(_on_state_changed)
	object.health_changed.connect(_on_health_changed)

func _ready():
	_load_sprite()

func _load_sprite():
	_sprite.texture = load(TEXTURE_LOCATION)
	add_child(_sprite)

func _on_health_changed():
	pass

func _on_state_changed():
	pass
