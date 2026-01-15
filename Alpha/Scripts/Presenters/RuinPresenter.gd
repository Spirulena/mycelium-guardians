class_name RuinPresenter
extends Node2D

const RUIN_1X1 = "res://Alpha/Core/Presenters/ObjectTextures/Structures/ruins/ruin1x1.png"
const RUIN_4X4 = "res://Alpha/Core/Presenters/ObjectTextures/Structures/ruins/ruin4x4.png"
const RUIN_6X6 = "res://Alpha/Core/Presenters/ObjectTextures/Structures/ruins/ruin6x6.png"

var _sprite: Sprite2D
var _model: RuinObject

# grabbing the layer to add a simple polygon onto the grid
var _tilemap: TileMapLayer
var _debug_polygon: Polygon2D

func _init(model: RuinObject, tilemap: TileMapLayer) -> void:
	_model = model
	_tilemap = tilemap

func _ready() -> void:
	_sprite = Sprite2D.new()
	_sprite.texture = _get_texture_for_size(_model.get_size())
	add_child(_sprite)
	
	_draw_debug_footprint()
	
	_model.state_changed.connect(_on_state_changed)
	_model.health_changed.connect(_on_health_changed)
	
	_on_state_changed({ "curr": _model.get_state() })
	_on_health_changed({ "curr": _model.get_health() })

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
func _draw_debug_footprint() -> void:
	var size: Vector2i = _model.get_size()
	var cell_size: Vector2 = _tilemap.tile_set.tile_size
	
	var width  = size.x * cell_size.x
	var height = size.y * cell_size.y
	
	_debug_polygon = Polygon2D.new()
	_debug_polygon.color = Color(0.997, 0.029, 0.0, 0.35)
	add_child(_debug_polygon)
	
	_debug_polygon.polygon = PackedVector2Array([
		Vector2(0, 0),
		Vector2(width * 0.5, height * 0.5),
		Vector2(0, height),
		Vector2(-width * 0.5, height * 0.5),
	])
	
	# polygon is being spawned at tile origin so this moves it to the visual top of the tile to fit the TileMapLayer
	_debug_polygon.position.y -= cell_size.y * 0.5
