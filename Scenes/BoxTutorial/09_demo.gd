class_name TutorialDemo extends LevelView

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var camera_component: LevelCameraComponent

func _ready() -> void:
	components_enable['HintsComponent'] = false
	components_enable['TileDebugComponent'] = false

	components_enable['PlaceMyceliumPathDefaultComponent'] = true
	components_enable['GroundPresenterComponent'] = true
	components_enable['TileObjectComponent'] = true
	components_enable['ChanceControllerComponent'] = true
	components_enable['MushroomNewMutationComponent'] = true

	super()
	level_controller.set_ignore_water_noise(false)

	load_level()
	components.get('MusicPlayerComponent').music.start_random_chords()
	camera_component = components.get("LevelCameraComponent")
	camera_component.camera2d.zoom = Vector2(1, 1)
	camera_component.camera2d.position = Vector2(0, 0)
	camera_component.camera2d.limit_left = -9000
	camera_component.camera2d.limit_right = 9000
	camera_component.camera2d.limit_top = -4250
	camera_component.camera2d.limit_bottom = 4250

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

	##Spawn some panels
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

	#for coords in plants_save.keys():
		#level_controller.add_object(
			#PlantObject.new(
				#coords,
				#plants_save[coords],
				#100,
				#))
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
