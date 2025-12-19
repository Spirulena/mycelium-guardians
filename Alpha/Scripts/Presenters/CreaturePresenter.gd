class_name CreaturePresenter
extends Node2D

# TODO: create function to differentiate object type
const TEXTURE_LOCATION = "res://Alpha/Sprites/Objects/creature.png" #placeholder sprite

var _sprite: Sprite2D
var _model: CreatureObject
var base_scale := Vector2.ONE

func _init(model: CreatureObject) -> void:
	_model = model

func _ready() -> void:
	_sprite = Sprite2D.new()
	_sprite.texture = load(TEXTURE_LOCATION)
	add_child(_sprite)
	
	# later replace with different textures
	match _model.get_subtype():
		CreatureObject.CreatureType.Worm:
			base_scale *= 0.8
		CreatureObject.CreatureType.Moths:
			base_scale *= 0.6
		CreatureObject.CreatureType.FFCrasher:
			base_scale *= 1.2
	
	_sprite.scale = base_scale
	
	_model.state_changed.connect(_on_state_changed)
	_model.health_changed.connect(_on_health_changed)
	
	_on_state_changed({ "curr": _model.get_state() })
	_on_health_changed({ "curr": _model.get_health() })
	
	#print(
		#"[CreaturePresenter]",
		#"subtype:", _model.get_subtype(),
		#"health:", _model.get_health(),
		#"coords:", _model.get_coords()
	#)

func _on_health_changed(change: Dictionary) -> void:
	var health: float = float(change.curr)
	var t: float = clampf(health / 100.0, 0.4, 1.0)
	_sprite.scale = Vector2.ONE * t

func _on_state_changed(change: Dictionary) -> void:
	var new_state: String = change.curr
	
	match new_state:
		ModelObject.State.None:
			_sprite.modulate = Color.WHITE
		ModelObject.State.Crashed:
			_sprite.modulate = Color(0.4, 0.4, 0.4)
		_:
			_sprite.modulate = Color.WHITE
