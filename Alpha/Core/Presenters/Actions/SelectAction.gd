extends GameAction
class_name SelectAction

signal selected_at(position: Vector2)

func _init(level_controller: LevelController, layer: TileMapLayer):
	_level_controller = level_controller
	_layer = layer
	cursor_texture = load("res://Alpha/Core/UI/UITextures/GridSprites/tileHighlight.png")

func _unhandled_input_handler(event: InputEvent, cursor_sprite: Sprite2D):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			var tile_position = _layer.get_local_mouse_position()
			tile_position = _position_to_gamecoords(_layer, tile_position)
			selected_at.emit(tile_position)
	elif event is InputEventMouseMotion:
		var snap_position = _layer.get_local_mouse_position()
		snap_position = _position_to_gamecoords(_layer, snap_position)
		snap_position = _gamecoords_to_position(_layer, snap_position)
		cursor_sprite.position = snap_position
