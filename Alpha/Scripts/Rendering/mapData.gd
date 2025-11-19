extends Node
class_name MapData

var GRASS : = preload("res://Alpha/Objects/Tiles/Grass.tscn")
var COBBLESTONE : = preload("res://Alpha/Objects/Tiles/Cobblestone.tscn")
var WATER : = preload("res://Alpha/Objects/Tiles/Water.tscn")

var width: int
var height: int
var stride: int
var tiles: Array = []

func generate(width: int, height: int, default_tile: PackedScene) -> void:
	self.width = width
	self.height = height
	self.stride = width
	
	tiles.resize(width * height)
	
	for i in tiles.size():
		tiles[i] = default_tile

func generate_patch(center: Vector2, radius: int, tile: PackedScene):
	for y in range(center.y - radius, center.y + radius + 1):
		for x in range(center.x - radius, center.x + radius + 1):
			if x < 0 or x >= width or y < 0 or y >= height:
				continue
				
			if Vector2(x, y).distance_to(center) <= radius:
				if randi() % 100 < 80:
					set_tile(x, y, tile)

func index(x: int, y: int) -> int:
	return y * stride + x

func get_tile(x: int, y: int) -> PackedScene:
	return tiles[index(x, y)]

func set_tile(x: int, y: int, tile: PackedScene) -> void:
	tiles[index(x, y)] = tile
