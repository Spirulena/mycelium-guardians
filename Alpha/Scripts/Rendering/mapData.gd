extends Node
class_name MapData

var GRASS : = preload("res://Alpha/Objects/Tiles/Grass.tscn")
var COBBLESTONE : = preload("res://Alpha/Objects/Tiles/Cobblestone.tscn")
var WATER : = preload("res://Alpha/Objects/Tiles/Water.tscn")

var map_data: Array = [
	[GRASS, GRASS, COBBLESTONE, COBBLESTONE],
	[GRASS, WATER, WATER, COBBLESTONE],
	[GRASS, WATER, WATER, COBBLESTONE],
	[GRASS, GRASS, COBBLESTONE, COBBLESTONE],
]

func insert(x: int, y: int, scene: PackedScene) -> void:
	if y < 0 or y >= map_data.size():
		return
	if x < 0 or x >= map_data[y].size():
		return
	
	map_data[y][x] = scene
