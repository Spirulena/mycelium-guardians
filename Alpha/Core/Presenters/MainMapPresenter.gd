extends Node2D
class_name MainMapPresenter

signal selection_changed(prev: TileObject, curr: TileObject)

@export var camera_3d: Camera3D
@export var tile_size: int = 256

var _current_action: GameAction
var _action_handler: Dictionary[GameAction.Action, GameAction]

var _current_selection: TileObject
var _level_controller: LevelController

func _ready() -> void:
	_level_controller = LevelController.new()
	_level_controller.model_changed.connect(_on_model_changed)
	_load_level()
	
	var select_action = SelectAction.new(_level_controller, $GroundLayer)
	select_action.selected_at.connect(func (position: Vector2):
		var previous_selection = _current_selection
		_current_selection = _level_controller.level_data.get_tile_at(position)
		selection_changed.emit(previous_selection, _current_selection)
	)
	_action_handler[GameAction.Action.SELECT] = select_action
	add_child(select_action)

	var grow_mycelium = GrowMyceliumAction.new(_level_controller, $GroundLayer)
	grow_mycelium.mycelium_grow.connect(func (start: Vector2i, end: Vector2i):
		print_debug("Grow mycelium from : ", start, " to: ", end)
	)
	_action_handler[GameAction.Action.GROW_MYCELIUM] = grow_mycelium
	add_child(grow_mycelium)

	var grow_building = GrowBuildingAction.new(_level_controller, $GroundLayer)
	_action_handler[GameAction.Action.GROW_BUILDING] = grow_building
	add_child(grow_building)

	_current_action = _action_handler[GameAction.Action.SELECT]

	set_action(GameAction.Action.SELECT)
	
	_current_selection = null

	get_parent().set_main_map_presenter(self)

func _process(_delta: float) -> void:
	if camera_3d:
		_sync_to_3d_camera()

func _sync_to_3d_camera() -> void:
	# Translate 3D origin to screen coordinates
	global_position = camera_3d.unproject_position(Vector3.ZERO)
	
	# Calculate 2D scale based on 3D Orthogonal Size
	var viewport_height = get_viewport().get_visible_rect().size.y
	var pixels_per_unit = viewport_height / camera_3d.size
	var s = pixels_per_unit / tile_size
	scale = Vector2(s, s)

func set_action(action: GameAction.Action) -> void:
	_current_action.cancel()
	_current_action.visible = false
	_current_action = _action_handler[action]
	_current_action.visible = true

func _gamecoords_to_position(layer: TileMapLayer, gamecoord: Vector2i) -> Vector2i:
	return layer.map_to_local(gamecoord)

func _position_to_gamecoords(layer: TileMapLayer, position: Vector2i) -> Vector2i:
	return layer.local_to_map(position)

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

				presenter.position = _gamecoords_to_position($GroundLayer, change.coords)
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
	_current_action._unhandled_input_handler(event)
