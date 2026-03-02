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

func _unhandled_input_handler(event: InputEvent, cursor_sprite: Sprite2D):
	pass

func _gamecoords_to_position(layer: TileMapLayer, gamecoord: Vector2i) -> Vector2i:
	return layer.map_to_local(gamecoord)

func _position_to_gamecoords(layer: TileMapLayer, position: Vector2i) -> Vector2i:
	return layer.local_to_map(position)
