class_name MyceliumPresenter
extends Node2D

const TEXTURE_LOCATION = "res://Alpha/Core/Presenters/ObjectTextures/Tiles/mycelium1.png" #placeholder sprite

var _sprite: Sprite2D
var _model: MyceliumObject

func _init(model: MyceliumObject):
	_model = model

func _ready() -> void:
	name = "mycelium_%d_%d" % [_model.coords.x, _model.coords.y]
	_sprite = Sprite2D.new()
	_sprite.texture = load(TEXTURE_LOCATION)
	add_child(_sprite)
	add_child(_debug_footprint())
	
	_model.state_changed.connect(_on_state_changed)
	_model.health_changed.connect(_on_health_changed)
	
	_on_state_changed({'curr': _model.get_state()})
	_on_health_changed({'curr': _model.get_health()})

func _on_health_changed(change: Dictionary) -> void:
	var health: float = float(change.curr)
	
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
	debug_polygon.color = Color(1.0, 1.0, 1.0, 0.35)
	debug_polygon.polygon = polygon
	var tile_size = (get_parent() as TileMapLayer).tile_set.tile_size
	debug_polygon.translate(Vector2i(-tile_size.x/2, -tile_size.y))
	return debug_polygon
