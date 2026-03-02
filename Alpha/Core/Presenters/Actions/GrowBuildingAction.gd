extends GameAction
class_name GrowBuildingAction

func _init(level_controller: LevelController, layer: TileMapLayer):
	_level_controller = level_controller
	_layer = layer
	transform = layer.transform
	name = "BuildingHighlight"
	cursor_texture = load("res://Alpha/Core/UI/UITextures/GhostObjects/ghostBuilding2.png")

func _unhandled_input_handler(event: InputEvent):
	_cursor_position = _position_to_gamecoords(_layer, _layer.get_local_mouse_position())
	queue_redraw()
