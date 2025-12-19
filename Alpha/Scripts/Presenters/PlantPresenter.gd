class_name PlantPresenter
extends Node2D

# TODO: create function to differentiate object type
const TEXTURE_LOCATION = "res://Alpha/Sprites/Objects/Plant.png" #placeholder sprite

var _sprite: Sprite2D
var _model: PlantObject

func _init(model: PlantObject) -> void:
	_model = model

func _ready() -> void:
	_sprite = Sprite2D.new()
	_sprite.texture = load(TEXTURE_LOCATION)
	add_child(_sprite)
	
	# later replace with different textures
	match _model.get_subtype():
		PlantObject.PlantType.DryGrass:
			_sprite.scale *= 0.7
		PlantObject.PlantType.Flower:
			_sprite.scale *= 0.6
		PlantObject.PlantType.Bush:
			_sprite.scale *= 0.9
		PlantObject.PlantType.Tree01, PlantObject.PlantType.Tree02:
			_sprite.scale *= 1.3
		PlantObject.PlantType.RoundCane_01:
			_sprite.scale *= 1.1
	
	_model.state_changed.connect(_on_state_changed)
	_model.health_changed.connect(_on_health_changed)
	
	_on_state_changed({ "curr": _model.get_state() })
	_on_health_changed({ "curr": _model.get_health() })
	
	#print(
		#"[PlantPresenter]",
		#"subtype:", _model.get_subtype(),
		#"state:", _model.get_state(),
		#"health:", _model.get_health(),
		#"coords:", _model.get_coords()
	#)

func _on_health_changed(change: Dictionary) -> void:
	var health: float = float(change.curr)
	var t: float = clampf(health / 100.0, 0.4, 1.0)
	_sprite.scale = _sprite.scale.normalized() * t

func _on_state_changed(change: Dictionary) -> void:
	var new_state: String = change.curr
	
	match new_state:
		PlantObject.PlantState.Growing:
			_sprite.modulate = Color(0.7, 1.0, 0.7)
		PlantObject.PlantState.Fruiting:
			_sprite.modulate = Color(0.9, 1.0, 0.5)
		PlantObject.PlantState.Crashed:
			_sprite.modulate = Color(0.4, 0.4, 0.4)
		_:
			_sprite.modulate = Color.WHITE
