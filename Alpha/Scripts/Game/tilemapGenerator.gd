extends TileMap

var center = Vector2i(-1, 0)
var radius = 10
var outline_thickness = 2

var fill_atlas = Vector2i(0, 0)
var outline_atlas = Vector2i(0, 1)

var iso_up := Vector2i(-1, -1)

@export var ground_layer: TileMapLayer
@export var obstacle_Layer: TileMapLayer

var level_controller: LevelController

func _ready() -> void:
	level_controller = LevelController.new()
	level_controller.model_changed.connect(_on_model_changed)
	load_level()

func _on_model_changed(change: Dictionary):
	if change.prev == null:
		# I'm using Node2D - your job is to actually create different classes/sprites/scenes for all
		# these objects and add them to the scene graph and make them visible on screen. The coords
		# are relative to the grid
		
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
				
				# diamond down isometric grid (64x32)
				presenter.position = Vector2((change.coords.x - change.coords.y) * 32, (change.coords.x + change.coords.y) * 16)
				
				presenter.name = "%s_%d_%d" % [change.type, change.coords.x, change.coords.y]
				add_child(presenter)
			_:
				pass

func load_level():
	level_controller.load_default_hints()
	level_controller.load_user_preferences()
	level_controller.save_user_preferences()

	var mycelium_positions = level_controller.level_data.get_base_coords()
	for coords in mycelium_positions:
		level_controller.add_object(MyceliumObject.new(coords))
		level_controller.get_tile_at(coords).set_discovered_in_radius(true, 5)

	var seed_mycelium = level_controller.get_tile_at(mycelium_positions[0]).get_mycelium()
	seed_mycelium.set_state(MyceliumObject.MyceliumState.Idle)
	seed_mycelium.set_health(100)

	var add: = [Vector2i(-2,1), Vector2i(-1, 1), Vector2i(0,1)]
	for coords in add:
		level_controller.add_object(MyceliumObject.new(coords))
		level_controller.get_tile_at(coords).set_discovered_in_radius(true, 5)

	## TEST ruin

	var coords = Vector2i(0, 20)
	var resources: Array[ResourceObject] = [
		ResourceObject.new(coords, ResourceObject.ResourceType.Minerals, 5000),
		ResourceObject.new(coords + Vector2i(0, 2), ResourceObject.ResourceType.Carbon, 2500),
		ResourceObject.new(coords + Vector2i(2, 2), ResourceObject.ResourceType.Water, 5000),
	]
	for resource in resources:
		level_controller.add_resource(resource)
	# When grown to ruin, expand mycelium for the size of ruin, all
	level_controller.add_object(
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
		level_controller.add_resource(resource)
	# When grown to ruin, expand mycelium for the size of ruin, all
	level_controller.add_object(
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
		level_controller.add_resource(resource)
	level_controller.add_object(
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
		level_controller.add_resource(resource)
	level_controller.add_object(
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
		level_controller.add_resource(resource)
	level_controller.add_object(
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
		level_controller.level_controller.add_resource(resource)
	level_controller.add_object(RuinObject.new(coords, Vector2i(1, 1), 'ruin_log_01', resources))

	coords = Vector2i(1, 11)
	resources = [ResourceObject.new(coords, ResourceObject.ResourceType.Carbon, 100)]
	for resource in resources:
		level_controller.add_resource(resource)
	level_controller.add_object(RuinObject.new(coords, Vector2i(1, 1), 'ruin_log_02', resources))

	coords = Vector2i(-1, 15)
	resources = [ResourceObject.new(coords, ResourceObject.ResourceType.Carbon, 100)]
	for resource in resources:
		level_controller.add_resource(resource)
	level_controller.add_object(RuinObject.new(coords, Vector2i(1, 1), 'ruin_log_01', resources))

	coords = Vector2i(-4,-4)
	var resources2:  Array[ResourceObject] = [ResourceObject.new(coords, ResourceObject.ResourceType.Carbon, 100)]
	for resource in resources2:
		level_controller.add_resource(resource)
	level_controller.add_object(RuinObject.new(coords, Vector2i(1, 1), 'ruin_log_02', resources2))

	coords = Vector2i(1, -6)
	var resources3:  Array[ResourceObject] = [ResourceObject.new(coords, ResourceObject.ResourceType.Carbon, 100)]
	for resource in resources3:
		level_controller.add_resource(resource)
	level_controller.add_object(RuinObject.new(coords, Vector2i(1, 1), 'ruin_log_01', resources3))

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
		level_controller.add_object(
			PlantObject.new(
				plant_coords,
				plants_save[plant_coords],
				100,
				))
	# Move it to the top
	# Add one on the bottom
	# FF Crasher 01
	#add_movable(CreatureObject.new(Vector2i(-44, 0), CreatureObject.CreatureType.FFCrasher))
	level_controller.add_movable(CreatureObject.new(Vector2i(-40, -40), CreatureObject.CreatureType.FFCrasher))
	level_controller.add_movable(CreatureObject.new(Vector2i(-30, 50), CreatureObject.CreatureType.FFCrasher))

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
