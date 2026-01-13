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
				add_child(presenter)

			_:
				pass

func _load_level():
	_level_controller.load_default_hints()
	_level_controller.load_user_preferences()
	_level_controller.save_user_preferences()

	var mycelium_positions = _level_controller.level_data.get_base_coords()
	for coords in mycelium_positions:
		_level_controller.add_object(MyceliumObject.new(coords))
		_level_controller.get_tile_at(coords).set_discovered_in_radius(true, 5)

	var seed_mycelium = _level_controller.get_tile_at(mycelium_positions[0]).get_mycelium()
	seed_mycelium.set_state(MyceliumObject.MyceliumState.Idle)
	seed_mycelium.set_health(100)

	var add: = [Vector2i(-2,1), Vector2i(-1, 1), Vector2i(0,1)]
	for coords in add:
		_level_controller.add_object(MyceliumObject.new(coords))
		_level_controller.get_tile_at(coords).set_discovered_in_radius(true, 5)

	## TEST ruin

	var coords = Vector2i(0, 20)
	var resources: Array[ResourceObject] = [
		ResourceObject.new(coords, ResourceObject.ResourceType.Minerals, 5000),
		ResourceObject.new(coords + Vector2i(0, 2), ResourceObject.ResourceType.Carbon, 2500),
		ResourceObject.new(coords + Vector2i(2, 2), ResourceObject.ResourceType.Water, 5000),
	]
	for resource in resources:
		_level_controller.add_resource(resource)
	# When grown to ruin, expand mycelium for the size of ruin, all
	_level_controller.add_object(
		RuinObject.new(
			coords,
			Vector2i(6, 6),
			'ruin_apartament_01',
			resources,
		)
	)

# More ruins
	coords = Vector2i(30, -20)
	resources = [
		ResourceObject.new(coords, ResourceObject.ResourceType.Minerals, 5000),
		ResourceObject.new(coords + Vector2i(0, 2), ResourceObject.ResourceType.Carbon, 2500),
		ResourceObject.new(coords + Vector2i(2, 2), ResourceObject.ResourceType.Water, 5000),
	]
	for resource in resources:
		_level_controller.add_resource(resource)
	# When grown to ruin, expand mycelium for the size of ruin, all
	_level_controller.add_object(
		RuinObject.new(
			coords,
			Vector2i(6, 6),
			'ruin_apartament_01',
			resources,
		)
	)


	# read resource coords from RuinData
	# Tank Ruin
	coords = Vector2i(4, 1)
	resources = [
		ResourceObject.new(coords, ResourceObject.ResourceType.Minerals, 500)
	]
	for resource in resources:
		_level_controller.add_resource(resource)
	_level_controller.add_object(
		RuinObject.new(
			coords,
			Vector2i(4, 4),
			'ruin_mainer_01',
			resources,
		)
	)

	# Tank Ruin
	coords = Vector2i(-10, -10)
	resources = [
		ResourceObject.new(coords, ResourceObject.ResourceType.Minerals, 2000)
	]
	for resource in resources:
		_level_controller.add_resource(resource)
	_level_controller.add_object(
		RuinObject.new(
			coords,
			Vector2i(1, 2),
			'ruin_tank_02',
			resources,
		)
	)

	# Tank Ruin
	coords = Vector2i(-15, -14)
	resources = [
		ResourceObject.new(coords, ResourceObject.ResourceType.Minerals, 2000)
	]
	for resource in resources:
		_level_controller.add_resource(resource)
	_level_controller.add_object(
		RuinObject.new(
			coords,
			Vector2i(1, 2),
			'ruin_tank_02',
			resources,
		)
	)

	coords = Vector2i(0, 7)
	resources = [ResourceObject.new(coords, ResourceObject.ResourceType.Carbon, 100)]
	for resource in resources:
		_level_controller.level_controller.add_resource(resource)
	_level_controller.add_object(RuinObject.new(coords, Vector2i(1, 1), 'ruin_log_01', resources))

	coords = Vector2i(1, 11)
	resources = [ResourceObject.new(coords, ResourceObject.ResourceType.Carbon, 100)]
	for resource in resources:
		_level_controller.add_resource(resource)
	_level_controller.add_object(RuinObject.new(coords, Vector2i(1, 1), 'ruin_log_02', resources))

	coords = Vector2i(-1, 15)
	resources = [ResourceObject.new(coords, ResourceObject.ResourceType.Carbon, 100)]
	for resource in resources:
		_level_controller.add_resource(resource)
	_level_controller.add_object(RuinObject.new(coords, Vector2i(1, 1), 'ruin_log_01', resources))

	coords = Vector2i(-4,-4)
	var resources2:  Array[ResourceObject] = [ResourceObject.new(coords, ResourceObject.ResourceType.Carbon, 100)]
	for resource in resources2:
		_level_controller.add_resource(resource)
	_level_controller.add_object(RuinObject.new(coords, Vector2i(1, 1), 'ruin_log_02', resources2))

	coords = Vector2i(1, -6)
	var resources3:  Array[ResourceObject] = [ResourceObject.new(coords, ResourceObject.ResourceType.Carbon, 100)]
	for resource in resources3:
		_level_controller.add_resource(resource)
	_level_controller.add_object(RuinObject.new(coords, Vector2i(1, 1), 'ruin_log_01', resources3))

	##Spawn some panelsCreature
	#for i in range(50):
		#for j in range(2):
			#add_object(
				#AIPanelObject.new(
					#Vector2i(-50 + i, -2 + j)
				#)
			#)
	# Plants
	var plants_save = {
		Vector2i(10,13): PlantObject.PlantType.Tree01,
		Vector2i(9,10): PlantObject.PlantType.DryGrass,
		Vector2i(9,11): PlantObject.PlantType.DryGrass,
		Vector2i(10,11): PlantObject.PlantType.DryGrass,
		Vector2i(7,9): PlantObject.PlantType.Bush,
	}

	for plant_coords in plants_save.keys():
		_level_controller.add_object(
			PlantObject.new(
				plant_coords,
				plants_save[plant_coords],
				100,
				))
	# Move it to the top
	# Add one on the bottom
	# FF Crasher 01
	#add_movable(CreatureObject.new(Vector2i(-44, 0), CreatureObject.CreatureType.FFCrasher))
	_level_controller.add_movable(CreatureObject.new(Vector2i(-40, -40), CreatureObject.CreatureType.FFCrasher))
	_level_controller.add_movable(CreatureObject.new(Vector2i(-30, 50), CreatureObject.CreatureType.FFCrasher))

	# test collide ff with ruin
	#add_movable(CreatureObject.new(Vector2i(-18, 5), CreatureObject.CreatureType.FFCrasher))
	#add_object(
		#RuinObject.new(
			#Vector2i(-6, 5),
			#Vector2i(6, 6),
			#'ruin_apartament_01',
			#resources,
		#)
	#)

func _unhandled_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			var tile_position = get_local_mouse_position()
			tile_position = _position_to_gamecoords(tile_position)
			
			var previous_selection = _current_selection
			_current_selection = _level_controller.get_tile_at(tile_position)
			selection_changed.emit(previous_selection, _current_selection)
	elif event is InputEventMouseMotion:
		var snap_position = get_local_mouse_position()
		snap_position = _position_to_gamecoords(snap_position)
		snap_position = _gamecoords_to_position(snap_position)
		_cursor_sprite.position = snap_position
