class_name CreaturePresenter
extends Node2D

const TEXTURE_LOCATION = "res://Alpha/Sprites/Objects/Creature.png" #placeholder sprite

var _sprite: Sprite2D
var _model: CreatureObject
var base_scale := Vector2.ONE

func _init(model: CreatureObject) -> void:
	_model = model

func _ready() -> void:
	name = "creature_%d_%d" % [_model.coords.x, _model.coords.y]
	_sprite = Sprite2D.new()
	_sprite.texture = load(TEXTURE_LOCATION)
	add_child(_sprite)
	add_child(_debug_footprint())
	
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

func _debug_footprint() -> Polygon2D:
	var origin = _model.coords
	var size = _model.size
	
	var vxs = [
		Vector2(0, 0),
		Vector2(size.x, 0),
		Vector2(size.x, size.y),
		Vector2(0, size.y),
	]
	var polygon = PackedVector2Array()
	for vx in vxs:
		polygon.append(get_parent().map_to_local(vx))
	
	var debug_polygon = Polygon2D.new()
	debug_polygon.color = Color(0.502, 0.004, 1.0, 0.349)
	debug_polygon.polygon = polygon
	var tile_size = (get_parent() as TileMapLayer).tile_set.tile_size
	debug_polygon.translate(Vector2i(-tile_size.x/2, -tile_size.y))
	return debug_polygon
