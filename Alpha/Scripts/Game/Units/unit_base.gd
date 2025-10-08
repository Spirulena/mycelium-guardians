extends Area2D
class_name Unit

const tile_size : Vector2 = Vector2(64, 32)

@onready var unit_highlight = $Highlight

@export var move_speed : float = 2

enum Team {Player, AI}
@export var team : Team

@export var tilemap_layer_node: TileMapLayer
@export var visual_path_line2D : Line2D

var pathfinding_grid: AStarGrid2D = AStarGrid2D.new()
var ai_paths: Array = []

func _ready():
	unit_highlight.visible = false
	global_position = snap_to_isometric(global_position, tile_size)
	visual_path_line2D.global_position = (Vector2(tile_size)/2)
	
	pathfinding_grid.region = tilemap_layer_node.get_used_rect()
	pathfinding_grid.cell_size = Vector2(tile_size)
	pathfinding_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_AT_LEAST_ONE_WALKABLE
	pathfinding_grid.update()
	
	for cell in tilemap_layer_node.get_used_cells():
		pathfinding_grid.set_point_solid(cell, true)
	
	var player_unit = null
	for unit in get_tree().get_nodes_in_group("Units"):
		if unit.team == Unit.Team.Player:
			player_unit = unit
			break
	
	move_ai()

func _process(delta):
	# input function mechanic
	pass

func move_ai():
	var player_unit = null
	for unit in get_tree().get_nodes_in_group("Units"):
		if unit.team == Unit.Team.Player:
			player_unit = unit
			break
	
	if player_unit:
		ai_paths = pathfinding_grid.get_point_path(
			global_position / tile_size,
			player_unit.global_position / tile_size
		)
		
	var go_to_position: Vector2 = ai_paths[0] + (Vector2(tile_size)/2)
	global_position = go_to_position
	
	visual_path_line2D.points = ai_paths

func snap_to_isometric(position: Vector2, tile_size_variable: Vector2) -> Vector2:
	var half_tile_size: Vector2 = tile_size_variable * .5
	
	var grid_x: float = round((position.x / half_tile_size.x + position.y / half_tile_size.y) * .5)
	var grid_y: float = round((position.y / half_tile_size.y - position.x / half_tile_size.x) * .5)
	
	return Vector2(grid_x-grid_y, grid_x+grid_y) * half_tile_size

# input function mechanic
# when right mouse button is clicked on the isometric grid, the unit (mycelium) will move towards tile and stop at tile while snapping to grid and showing its path using the line2D (debug)

func _on_mouse_entered() -> void:
	unit_highlight.visible = true

func _on_mouse_exited() -> void:
	unit_highlight.visible = false
