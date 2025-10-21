class_name MovementUtils
extends Node

static func get_path_to_tile(
	start_pos: Vector2,
	target_pos: Vector2,
	tilemap: TileMapLayer,
	blocked_layer: TileMapLayer
) -> PackedVector2Array:
	print("Start pos (world): ", start_pos)
	print("Target pos (world): ", target_pos)
	
	var start_tile = tilemap.local_to_map(start_pos)
	var end_tile = tilemap.local_to_map(target_pos)
	
	print("Start tile (map): ", start_tile)
	print("End tile (map): ", end_tile)
	
	if start_tile == end_tile:
		print("Start and end tiles are the same")
		return PackedVector2Array([])
	
	var all_tiles = tilemap.get_used_cells()
	var blocked_tiles = blocked_layer.get_used_cells()
	var walkable_tiles = all_tiles.filter(func(tile): return not blocked_tiles.has(tile))
	print("Total tiles: ", all_tiles.size(), ", Blocked tiles: ", blocked_tiles.size(), ", Walkable tiles: ", walkable_tiles.size())
	
	var astar = AStar2D.new()
	
	for tile in walkable_tiles:
		var point_id = _get_point_id(tile)
		astar.add_point(point_id, Vector2(tile))
	
	for tile in walkable_tiles:
		var point_id = _get_point_id(tile)
		
		for neighbor in _get_neighbors(tile):
			if walkable_tiles.has(neighbor):
				var neighbor_id = _get_point_id(neighbor)
				if not astar.are_points_connected(point_id, neighbor_id):
					astar.connect_points(point_id, neighbor_id)
	
	var start_id = _get_point_id(start_tile)
	var end_id = _get_point_id(end_tile)
	
	if not astar.has_point(start_id) or not astar.has_point(end_id):
		print("No valid path: start or end point not in graph")
		return PackedVector2Array([])
	
	var tile_path = astar.get_point_path(start_id, end_id)
	
	var world_path: PackedVector2Array = PackedVector2Array([])
	for tile_pos in tile_path:
		var world_pos = tilemap.map_to_local(Vector2i(tile_pos))
		world_path.append(world_pos)
		print("Adding world pos to path: ", world_pos)
	
	print("Final path length: ", world_path.size())
	if world_path.is_empty():
		print("Warning: Generated path is empty!")
	else:
		print("First path point: ", world_path[0])
	return world_path

static func _get_point_id(tile: Vector2i) -> int:
	var a = tile.x + 10000
	var b = tile.y + 10000
	return (a + b) * (a + b + 1) / 2 + b

static func _get_neighbors(tile: Vector2i) -> Array[Vector2i]:
	var neighbors: Array[Vector2i] = []
	neighbors.append(Vector2i(tile.x + 1, tile.y))
	neighbors.append(Vector2i(tile.x - 1, tile.y))
	neighbors.append(Vector2i(tile.x, tile.y + 1))
	neighbors.append(Vector2i(tile.x, tile.y - 1))
	return neighbors
