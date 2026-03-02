extends GameAction
class_name GrowMyceliumAction

signal mycelium_grow(start: Vector2i, end: Vector2i)

var _active_mycelium: bool
var _started_mycelium_at: Vector2

func _init(level_controller: LevelController, layer: TileMapLayer):
	_level_controller = level_controller
	_layer = layer
	transform = layer.transform
	name = "MyceliumHighlight"
	cursor_texture = load("res://Alpha/Core/Objects/ObjectTextures/Tiles/mycelium1.png")
	_active_mycelium = false

func cancel():
	if _active_mycelium:
		_active_mycelium = false

func _unhandled_input_handler(event: InputEvent):
	if event is InputEventMouseButton:
		if event.pressed:
			var tile_position = _layer.get_local_mouse_position()
			tile_position = _position_to_gamecoords(_layer, tile_position)

			match event.button_index:
				MOUSE_BUTTON_LEFT when not _active_mycelium:
					_active_mycelium = true
					_started_mycelium_at = tile_position
				MOUSE_BUTTON_LEFT when _active_mycelium:
					_active_mycelium = false
					mycelium_grow.emit(_started_mycelium_at, tile_position)
				MOUSE_BUTTON_RIGHT when _active_mycelium:
					_active_mycelium = false
					queue_redraw()

	_cursor_position = _position_to_gamecoords(_layer, _layer.get_local_mouse_position())
	queue_redraw()

func _draw_dda_line(from: Vector2i, to: Vector2i, texture: Texture2D):
	var tile_size = _layer.tile_set.tile_size

	var dx := to.x - from.x
	var dy := to.y - from.y
	var steps := maxi(absi(dx), absi(dy))

	if steps == 0:
		draw_texture(texture, _layer.map_to_local(Vector2(from)) + Vector2(-tile_size.x/2, -tile_size.y/2))
		return

	var x_inc := float(dx) / steps
	var y_inc := float(dy) / steps

	var x := float(from.x)
	var y := float(from.y)

	for i in range(steps + 1):
		draw_texture(texture, _layer.map_to_local(Vector2(roundi(x), roundi(y))) + Vector2(-tile_size.x/2, -tile_size.y/2))
		x += x_inc
		y += y_inc

func _draw():
	if _active_mycelium:
		_draw_dda_line(_started_mycelium_at, _cursor_position, cursor_texture)
		#draw_line(_layer.map_to_local(_started_mycelium_at), _layer.map_to_local(_last_mycelium_at), Color(0.997, 0.029, 0.0, 0.35), 10)
	else:
		var tile_size = _layer.tile_set.tile_size
		draw_texture(cursor_texture, _layer.map_to_local(_cursor_position) + Vector2(-tile_size.x/2, -tile_size.y/2))
