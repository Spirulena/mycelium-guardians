extends Node2D

@onready var groundLayer: TileMapLayer = $GroundLayer
@onready var obstacleLayer: TileMapLayer = $ObstacleLayer

var hover_effect: Polygon2D
const TILE_SIZE := Vector2(64, 32)

func _ready() -> void:
	setup_hover_polygon()

func _process(_delta: float) -> void:
	handle_hover_effect()

func setup_hover_polygon() -> void:
	hover_effect = Polygon2D.new()
	hover_effect.polygon = PackedVector2Array([
		Vector2(0, -16),
		Vector2(32, 0),
		Vector2(0, 16),
		Vector2(-32, 0)
	])
	hover_effect.color = Color(1, 1, 1, 0.2)
	hover_effect.visible = false
	add_child(hover_effect)

func handle_hover_effect() -> void:
	var mouse_pos = get_local_mouse_position()
	var snapped_pos = snap_to_isometric(mouse_pos, TILE_SIZE)
	
	var cell = groundLayer.local_to_map(snapped_pos)

	var has_ground = groundLayer.get_cell_source_id(cell) != -1
	var has_obstacle = obstacleLayer.get_cell_source_id(cell) != -1

	if has_ground and not has_obstacle:
		hover_effect.position = groundLayer.map_to_local(cell)
		hover_effect.visible = true
	else:
		hover_effect.visible = false

func snap_to_isometric(position: Vector2, tile_size_variable: Vector2) -> Vector2:
	var half_tile_size: Vector2 = tile_size_variable * 0.5
	
	var grid_x: float = round((position.x / half_tile_size.x + position.y / half_tile_size.y) * 0.5)
	var grid_y: float = round((position.y / half_tile_size.y - position.x / half_tile_size.x) * 0.5)
	
	return Vector2(grid_x - grid_y, grid_x + grid_y) * half_tile_size
