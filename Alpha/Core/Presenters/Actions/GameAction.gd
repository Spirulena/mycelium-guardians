extends Node2D
class_name GameAction

@export
var cursor_texture: Texture2D

enum Action {
	SELECT,
	GROW_MYCELIUM,
	GROW_BUILDING,
}

var _level_controller: LevelController
var _layer: TileMapLayer
var _cursor_position: Vector2i

func cancel():
	pass

func _unhandled_input_handler(event: InputEvent):
	pass

func _gamecoords_to_position(layer: TileMapLayer, gamecoord: Vector2i) -> Vector2i:
	return layer.map_to_local(gamecoord)

func _position_to_gamecoords(layer: TileMapLayer, position: Vector2i) -> Vector2i:
	return layer.local_to_map(position)

func _draw():
		var tile_size = _layer.tile_set.tile_size
		draw_texture(cursor_texture, _layer.map_to_local(_cursor_position) + Vector2(-tile_size.x/2, -tile_size.y/2))
