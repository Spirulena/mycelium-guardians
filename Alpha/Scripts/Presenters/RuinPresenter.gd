class_name RuinPresenter
extends Node2D

const RUIN_1X1 = "res://Alpha/Core/Presenters/ObjectTextures/Structures/ruins/ruin1x1.png"
const RUIN_4X4 = "res://Alpha/Core/Presenters/ObjectTextures/Structures/ruins/ruin4x4.png"
const RUIN_6X6 = "res://Alpha/Core/Presenters/ObjectTextures/Structures/ruins/ruin6x6.png"

var _sprite: Sprite2D
var _model: RuinObject

func _init(model: RuinObject) -> void:
	_model = model

func _ready() -> void:
	name = "ruin_%d_%d" % [_model.coords.x, _model.coords.y]
	_sprite = Sprite2D.new()
	_sprite.texture = _get_texture_for_size(_model.size)
	add_child(_sprite)
	add_child(_debug_footprint())
	
	_model.state_changed.connect(_on_state_changed)
	_model.health_changed.connect(_on_health_changed)

func _get_texture_for_size(size: Vector2i) -> Texture2D:
	match size:
		Vector2i(1, 1):
			return load(RUIN_1X1)
		Vector2i(4, 4):
			return load(RUIN_4X4)
		Vector2i(6, 6):
			return load(RUIN_6X6)
		_:
			push_warning("No ruin texture for size %s" % size)
			# can put any backup ruin here but i just put the 1x1 for now
			return load(RUIN_1X1)

func _on_health_changed(change: Dictionary) -> void:
	var health: float = float(change.curr)
	var t: float = clampf(health / 100.0, 0.35, 1.0)
	_sprite.modulate = Color(1, 1, 1, t)

func _on_state_changed(change: Dictionary) -> void:
	var new_state: String = change.curr
	
	match new_state:
		ModelObject.State.Crashed:
			_sprite.modulate = Color(0.4, 0.4, 0.4)
		ModelObject.State.Removed:
			queue_free()
		_:
			_sprite.modulate = Color.WHITE

# function to draw out a simple polygon onto the grid to showcase the ruin size
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
	debug_polygon.color = Color(0.997, 0.029, 0.0, 0.35)
	debug_polygon.polygon = polygon
	var tile_size = (get_parent() as TileMapLayer).tile_set.tile_size
	debug_polygon.translate(Vector2i(-tile_size.x/2, -tile_size.y))
	return debug_polygon
