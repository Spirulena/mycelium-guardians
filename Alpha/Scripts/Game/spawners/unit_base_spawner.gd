extends Node2D
class_name UnitSpawner

var num_units : int = 3 #how many units this spawner has
var total_units : int = 0 #how many units are out in the scene

var groundLayer: TileMapLayer
var obstacleLayer: Array[TileMapLayer]

@export var player_unit: PackedScene

@export var num_units_label : Label
@export var total_units_label : Label

var spawnable_tiles: Array[Vector2i] = []

func _ready():
	update_label()
	groundLayer = TilemapGrid.instance.groundLayer
	obstacleLayer = TilemapGrid.instance.obstacleLayer

func _process(delta: float):
	update_spawnable_tiles()

func update_spawnable_tiles():
	spawnable_tiles.clear()
	
	var all_tiles = groundLayer.get_used_cells()
	
	var obstacles: Array[Vector2i] = []
	for layer in obstacleLayer:
		obstacles.append_array(layer.get_used_cells())
	
	for tile in all_tiles:
		if not obstacles.has(tile):
			spawnable_tiles.append(tile)

func update_label():
	if num_units_label:
		num_units_label.text = str(num_units)
	
	if total_units_label:
		total_units_label.text = str(total_units)

func spawn_unit():
	if num_units <= 0:
		print("no more units available to spawn")
		return
	
	if spawnable_tiles.is_empty():
		print("no available tiles to spawn unit")
		return
	
	var random_tile = spawnable_tiles[randi() % spawnable_tiles.size()]
	
	var world_pos = groundLayer.map_to_local(random_tile)
	world_pos = groundLayer.to_global(world_pos)
	
	var unit = player_unit.instantiate()
	
	get_tree().current_scene.add_child(unit)
	
	unit.global_position = world_pos
	
	num_units -= 1
	total_units += 1
	update_label()
