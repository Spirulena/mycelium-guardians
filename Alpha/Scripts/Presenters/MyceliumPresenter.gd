class_name MyceliumPresenter
extends Node2D

const TEXTURE_LOCATION = "res://Alpha/Sprites/Objects/Mycelium.png" #placeholder sprite

var _sprite: Sprite2D
var _model: MyceliumObject

func _init(model: MyceliumObject):
	_model = model

func _ready() -> void:
	_sprite = Sprite2D.new()
	_sprite.texture = load(TEXTURE_LOCATION)
	add_child(_sprite)
	
	_model.state_changed.connect(_on_state_changed)
	_model.health_changed.connect(_on_health_changed)
	
	_on_state_changed({'curr': _model.get_state()})
	_on_health_changed({'curr': _model.get_health()})

func _on_health_changed(change: Dictionary) -> void:
	var health: float = float(change.curr)
	#print("Mycelium @", _model.get_coords(), " health:", health)
	
	var t: float = clampf(health / 100.0, 0.3, 1.0)
	_sprite.scale = Vector2.ONE * t

func _on_state_changed(change: Dictionary) -> void:
	var new_state = change.curr
	
	match new_state:
		MyceliumObject.MyceliumState.Growing:
			_sprite.modulate = Color(0.6, 1.0, 0.6)
		MyceliumObject.MyceliumState.Thickened:
			_sprite.modulate = Color(0.2, 0.8, 0.2)
		MyceliumObject.MyceliumState.Crashed:
			_sprite.modulate = Color.GRAY
		_:
			_sprite.modulate = Color.WHITE
