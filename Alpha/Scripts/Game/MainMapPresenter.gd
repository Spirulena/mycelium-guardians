extends Node2D
class_name MainMapPresenter

signal selection_changed(prev: TileObject, curr: TileObject)

var _current_action: GameplayPresenter.Action
var _cursor_sprite: Sprite2D
var _cursor_sprite_action_texture: Dictionary[GameplayPresenter.Action, Texture2D]

var _current_selection: TileObject

var _level_controller: LevelController

func set_action(action: GameplayPresenter.Action) -> void:
	_current_action = action
	_cursor_sprite.texture = _cursor_sprite_action_texture[_current_action]

func _ready() -> void:
	_level_controller = LevelController.new()
	_level_controller.model_changed.connect(_on_model_changed)
	_load_level()
	
	_cursor_sprite_action_texture[GameplayPresenter.Action.SELECT] = load("res://Alpha/Core/Presenters/UITextures/GridSprites/tileHighlight.png")
	_cursor_sprite_action_texture[GameplayPresenter.Action.GROW_MYCELIUM] = load("res://Alpha/Core/Presenters/ObjectTextures/Tiles/mycelium1.png")
	_cursor_sprite_action_texture[GameplayPresenter.Action.GROW_BUILDING] = load("res://Alpha/Core/Presenters/UITextures/GhostObjects/ghostBuilding2.png")

	_current_action = GameplayPresenter.Action.SELECT

	_cursor_sprite = Sprite2D.new()
	_cursor_sprite.name = "cursor_node"
	_cursor_sprite.texture = _cursor_sprite_action_texture[_current_action]
	add_child(_cursor_sprite)
	
	_current_selection = null

	get_parent().set_main_map_presenter(self)

func _gamecoords_to_position(gamecoord: Vector2i) -> Vector2i:
	return $GroundLayer.map_to_local(gamecoord)

func _position_to_gamecoords(position: Vector2i) -> Vector2i:
	return $GroundLayer.local_to_map(position)

func _on_model_changed(change: Dictionary):
	if change.prev == null:
		var presenter

		match change.type:
			"ruin":
				presenter = RuinPresenter.new(change.curr)
			"mycelium":
				presenter = MyceliumPresenter.new(change.curr)
			"plant":
				presenter = PlantPresenter.new(change.curr)
			"creature":
				presenter = CreaturePresenter.new(change.curr)

		match change.type:
			"ruin", "mycelium", "plant", "creature":

				change.curr.state_changed.connect(presenter._on_state_changed)
				change.curr.state_changed.connect(presenter._on_health_changed)

				presenter.position = _gamecoords_to_position(change.coords)

				presenter.name = "%s_%d_%d" % [change.type, change.coords.x, change.coords.y]
				$GroundLayer.add_child(presenter)

			_:
				pass

func _load_level():
	_level_controller.add_object(
		RuinObject.new(
			Vector2i(0, 20),
			Vector2i(6, 6),
			'ruin_apartament_01',
		)
	)

	_level_controller.add_object(
		RuinObject.new(
			Vector2i(30, -20),
			Vector2i(6, 6),
			'ruin_apartament_01',
		)
	)

	_level_controller.add_object(
		RuinObject.new(
			Vector2i(4, 1),
			Vector2i(4, 4),
			'ruin_mainer_01',
		)
	)

	_level_controller.add_object(
		RuinObject.new(
			Vector2i(-10, -10),
			Vector2i(1, 2),
			'ruin_tank_02',
		)
	)

	_level_controller.add_object(
		RuinObject.new(
			Vector2i(-15, -14),
			Vector2i(1, 2),
			'ruin_tank_02',
		)
	)
#
	_level_controller.add_object(RuinObject.new(Vector2i(0, 7), Vector2i(1, 1), 'ruin_log_01'))
	_level_controller.add_object(RuinObject.new(Vector2i(1, 11), Vector2i(1, 1), 'ruin_log_02'))
	_level_controller.add_object(RuinObject.new(Vector2i(-4,-4), Vector2i(1, 1), 'ruin_log_02'))
	_level_controller.add_object(RuinObject.new(Vector2i(1, -6), Vector2i(1, 1), 'ruin_log_01'))

	var plants_save = {
		Vector2i(10,13): PlantObject.PlantType.Tree01,
		Vector2i(9,10): PlantObject.PlantType.DryGrass,
		Vector2i(9,11): PlantObject.PlantType.DryGrass,
		Vector2i(10,11): PlantObject.PlantType.DryGrass,
		Vector2i(7,9): PlantObject.PlantType.Bush,
	}
	for plant_coords in plants_save:
		_level_controller.add_object(
			PlantObject.new(
				plant_coords,
				plants_save[plant_coords],
				100,
				))

func _unhandled_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			var tile_position = get_local_mouse_position()
			tile_position = _position_to_gamecoords(tile_position)
			
			var previous_selection = _current_selection
			_current_selection = _level_controller.level_data.get_tile_at(tile_position)
			selection_changed.emit(previous_selection, _current_selection)
	elif event is InputEventMouseMotion:
		var snap_position = get_local_mouse_position()
		snap_position = _position_to_gamecoords(snap_position)
		snap_position = _gamecoords_to_position(snap_position)
		_cursor_sprite.position = snap_position
