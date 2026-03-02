extends GameAction
class_name SelectAction

signal selected_at(position: Vector2)

func _init(level_controller: LevelController, layer: TileMapLayer):
	_level_controller = level_controller
	_layer = layer
	transform = layer.transform
	name = "SelectHighlight"
	cursor_texture = load("res://Alpha/Core/UI/UITextures/GridSprites/tileHighlight.png")

func _unhandled_input_handler(event: InputEvent):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			var tile_position = _layer.get_local_mouse_position()
			tile_position = _position_to_gamecoords(_layer, tile_position)
			selected_at.emit(tile_position)

	_cursor_position = _position_to_gamecoords(_layer, _layer.get_local_mouse_position())
	queue_redraw()
