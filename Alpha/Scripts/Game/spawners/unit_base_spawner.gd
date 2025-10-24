extends Node2D
class_name UnitSpawner

var num_units : int = 0 #how many units this spawner has
var total_units : int = 0 #how many units are out in the scene

@export var groundLayer: TileMapLayer
@export var obstacleLayer: Array[TileMapLayer]
# reference layers from tilemapgrid in the future

@export var player_unit: PackedScene

# reference to label ui

var spawnable_tiles: Array[Vector2i] = []

func _process(delta: float):
	update_spawnable_tiles()
	# update label function

func update_spawnable_tiles():
	spawnable_tiles.clear()
	
	var all_tiles = groundLayer.get_used_cells()
	
	var obstacles: Array[Vector2i] = []
	for layer in obstacleLayer:
		obstacles.append_array(layer.get_used_cells())
	
	for tile in all_tiles:
		if not obstacles.has(tile):
			spawnable_tiles.append(tile)

# update label funciton

func spawn_unit():
	# needs the layers to be referenced from tilemapgrid first
	print("Spawned unit")
