class_name Loader extends Object

static var loader

static func get_loader()-> Loader:
	if loader == null:
		loader = Loader.new()
	return loader

var scenes: Dictionary

# TODO: set paths in editor so that it can be updated by editor
var all_paths: Dictionary = {
	#'Mycelium': "res://Scenes/Mycelium/mycelium/v1/MyceliumScene_v1.tscn",
	'Mycelium': "res://Scenes/Mycelium/mycelium/v3/MyceliumScene_v3.tscn",
	#'Mycelium': "res://Scenes/Mycelium/mycelium/v2/MyceliumScene_v2.tscn",
	'mycelium_queue': "res://Scenes/Mycelium/queue/mycelium_queue.tscn",
	'mycelium_growing': "res://Scenes/Mycelium/growing/mycelium_growing.tscn",
	'MyceliumPreview': "res://Scenes/Mycelium/mycelium_preview/v1/MyceliumPreview_v1.tscn",
	'resource_found_animation': "res://Scenes/ui_elements/resources_found/resource_found_instance.tscn",
	'harvest_ui_element': "res://Scenes/ui_elements/harvest_ui_element/harvest_ui_element.tscn",
	'camera2d_scene': "res://Scenes/Camera/camera_2d.tscn",
	'storage_added_scene': "res://Scenes/ui_elements/storage_added/storage_added.tscn",
	'growth_over_panels_scene': "res://Scenes/Mycelium/MyceliumOverPanel_01/grow_over_panels_test_01.tscn",
	'heal_tile_ui_animation': "res://Scenes/Animations/Heal/heal_tile_animation.tscn",
	'heal_structure_ui_animation': "res://Scenes/Animations/Heal/heal_structure_animation.tscn",
	'resource_ball_scene': "res://Scenes/ResourceBall/ResourceBall.tscn",
	'resource_ball_scene2': "res://Scenes/ResourceBall/ResourceBall2.tscn",
	'game_ui_scene': "res://UI/gui.tscn",
	'single_hint_window': "res://Scenes/ui_elements/SingleHintWindow/SingleHintWindow.tscn",
	'sfx_player': "res://Sound/SfxPlayer.tscn",
	'sound': "res://Sound/sound.tscn",
	'harvester_controller': "res://Controllers/HarvesterController.gd",
	#'SmogTileShader': "res://Scenes/Smog/SmogTileMovingTexture.tscn",
	#'SmogTileShader2': "res://Scenes/Smog/SmogTileMovingTexture2.tscn",
	'SmogTileShader3': "res://Scenes/Smog/SmogTileMovingTexture3.tscn",
	'SmogTileShader512': "res://Scenes/Smog/SmogTileMovingTexture512.tscn",
	'mycelium_health_overlay': "res://Scenes/Overlay/MyceliumHealth/MyceliumHealthOverlay.tscn",
	'smog_overlay': "res://Scenes/Overlay/Smog/SmogOverlay.tscn",
	'radiation_overlay': "res://Scenes/Overlay/Radiation/RadiationOverlay.tscn",
	'water_overlay': "res://Scenes/Overlay/Water/WaterOverlay.tscn",
	'water_storage_overlay': "res://Scenes/Overlay/WaterStorage/WaterStorageOverlay.tscn",
	'energy_storage_overlay': "res://Scenes/Overlay/EnergyStorage/EnergyStorageOverlay.tscn",
	'minerals_storage_overlay': "res://Scenes/Overlay/MineralsStorage/MineralsStorageOverlay.tscn",
	'carbon_storage_overlay': "res://Scenes/Overlay/CarbonStorage/CarbonStorageOverlay.tscn",
	'base': "res://Scenes/Structures/base/base.tscn",
	'LegacyTileSelection': "res://Scenes/LegacySelection/LegacySelection.tscn",
	'CanBuildHereTileMap': "res://Scenes/CanBuildHere/CanBuildHere.tscn",
	'select_structure_button': "res://Scenes/ui_elements/build_menu/add_building_button.tscn",
	'select_structure_button_preview': "res://UI/build_menu/preview_button.tscn",
	'isometric_rectangle': "res://Scenes/ui_elements/isometric_rectangle/isometric_rectangle.tscn",
	'effect_radius': "res://Scenes/Structures/effect_radius.tscn",
	'selected_structure_map_ui': "res://Scenes/Structures/selected_structure.tscn",
	# Creatures
	'worm': "res://Scenes/Creatures/worm_blockout/Worm.tscn",
	'moths': "res://Scenes/Creatures/Moth_01/moths_01.tscn",
	# Movable AGI
	'ff_crasher_01': "res://Scenes/AGI/ff_crasher_01.tscn",
	# Plants
	'round_cane_01': "res://Scenes/Plants/RoundCane_01/RoundCane_01.tscn",
	'dry_grass': "res://Scenes/Plants/DryGrass_01/dryland_grass_anim_01.tscn",
	'bush': "res://Scenes/Plants/Bush_01/bush_01_placeholder.tscn",
	'flower': "res://Scenes/Plants/Flowers/flowers_01_placeholder.tscn",
	'tree_01': "res://Scenes/Plants/Tree_01/trees_01_placeholder.tscn",
	'tree_02': "res://Scenes/Plants/Tree_02/Pittosporum_002.tscn",
	'ruin_apartament_01': "res://Scenes/Ruins/Apartament_01/Apartament_01.tscn",
	'ruin_tank_01': "res://Scenes/Ruins/Tank01/ruin_tank_01.tscn",
	'ruin_tank_02': "res://Scenes/Ruins/Tank02/ruin_tank_02.tscn",
	'ruin_mainer_01': "res://Scenes/Ruins/Miners_Ruin_01/miner_ruin.tscn",
	'ruin_log_01': "res://Scenes/Ruins/ruin_log_01/ruin_log_01.tscn",
	'ruin_log_02': "res://Scenes/Ruins/ruin_log_02/ruin_log_02.tscn",
	'ruin_tree_stump_01': "res://Scenes/Ruins/tree_stump_01/tree_stump_01.tscn",
	'ruin_tree_stump_01_256': "res://Scenes/Ruins/tree_stump_01_256/tree_stump_01.tscn",
	'ruin_organic_matter': "res://Scenes/Ruins/organic_matter_01/organic_matter_01.tscn",
	'ruin_apartament_mycelium_frames': "res://Assets/structures/history_obj/apartament_complex/cover_frames_webp.tres",
	'ruin_apartament_mycelium_frames_short': "res://Assets/structures/history_obj/apartament_complex/cover_frames_webp_short.tres",
	# panels
	'panels_tile_set': "res://Assets/TileSets/panels.tres",
	# genes
	'mutation_icon': "res://Scenes/Genes/MutationIcon/mutation_icon.tscn",
	#'panel_in_transit': "res://Scenes/Panels/Panel_in_transit/panel_in_transit.tscn",
	#BuildingObject.StructureType.Storage_Water: "res://Scenes/Structures/storage/h2o/h2o_storage.tscn",
	##BuildingObject.StructureType.Storage_Energy: "res://Scenes/Structures/storage/energy/energy.tscn",
	#BuildingObject.StructureType.Storage_Energy: "res://Scenes/Structures/storage/energy/energy_pinecone.tscn",
	#BuildingObject.StructureType.Storage_Minerals: "res://Scenes/Structures/storage/minerals/minerals.tscn",
	#BuildingObject.StructureType.Storage_Carbon: "res://Scenes/Structures/storage/carbon/carbon.tscn",
	#BuildingObject.StructureType.Absorber_Smog: "res://Scenes/Structures/absorbers/smog/smog.tscn",
	#BuildingObject.StructureType.Absorber_Smog: "res://Scenes/Structures/absorbers/smog/smog_egg.tscn",
	BuildingObject.StructureType.Absorber_Smog: "res://Scenes/Structures/absorbers/smog/melo_lungs/mello.tscn",
	BuildingObject.StructureType.Absorber_Radiation: "res://Scenes/Structures/absorbers/radiation/radiation.tscn",
	#BuildingObject.StructureType.Emitter_Spore: "res://Scenes/Structures/emitters/spore/spore_tower_1.tscn",
	BuildingObject.StructureType.Export_Center: "res://Scenes/Structures/emitters/export_center/export_center.tscn",
	'ruins_backstory_window': "res://Scenes/Ruins/RuinsBackstoryTextWindow/RuinsBackstoryTextWindow.tscn",
	'ruins_decompose_progress_display': "res://Scenes/Ruins/DecomposeProgressDisplay/DecomposeProgressDisplay.tscn",
	'ruins_decompose_ruin_button': "res://Scenes/Ruins/DecomposeRuinButton/DecomposeRuinButton.tscn",
	'growth_emitter': "res://Scenes/Structures/vfx/Growth_Emitter/growth_emitter.tscn",
	#'growth_finished_efx_scene': "res://Scenes/Structures/vfx/Growth_Finished_Indicator/structure_pop.tscn",
	'tile_debug_menu': "res://Scenes/Debug/TileDebugPresenter/Menu.tscn",
	'decompose_button': "res://Scenes/ui_elements/decompose_button/decompose_button.tscn",
}

var not_preloaded: Dictionary = {
	'tutorial_01_mycelium': "res://Scenes/BoxTutorial/tutorial_01_mycelium.tscn",
	'tutorial_02_camera': "res://Scenes/BoxTutorial/tutorial_02_camera.tscn",
	'tutorial_03_earth_destroyed': "res://Scenes/BoxTutorial/earth_destroyed.tscn",
	'tutorial_04_water': "res://Scenes/BoxTutorial/04_water.tscn",
	'tutorial_05_energy': "res://Scenes/BoxTutorial/05_energy.tscn",
	'tutorial_06_minerals': "res://Scenes/BoxTutorial/06_minerals.tscn",
	'tutorial_07_export': "res://Scenes/BoxTutorial/07_export_center.tscn",
	'tutorial_08_export': "res://Scenes/BoxTutorial/08_enzymes.tscn",
	'tutorial_09_demo': "res://Scenes/BoxTutorial/09_demo.tscn",
	'level_01': "res://Scenes/Levels/Level_01.tscn",
	'journey_01': "res://Scenes/Levels/Journey/Journey_01.tscn",
	'elements_01': "res://Scenes/Levels/Elements/Elements_01.tscn",
	'level_test_empty': "res://Scenes/Levels/Level_test_empty.tscn",
	}

# trigger loading
func load_all_from_path(dict: Dictionary = all_paths):
	for path in dict.values():
		if not path.is_empty():
			ResourceLoader.load_threaded_request(path)

# Or return the reference to the cache ? eg. key to access ?
# Have a global cache dictionary with all scenes ?
# return hash ? to it ? or status if loaded ?
func return_scene(id, path_dict: Dictionary = all_paths, scenes_dict: Dictionary = scenes):

	if scenes_dict.has(id):
		return scenes_dict.get(id)
	# add check for loaded state ?

	# if preloaded
	if path_dict.has(id):
		# or pull the scene
		var path = path_dict.get(id)
		scenes_dict[id] = ResourceLoader.load_threaded_get(path)

		return scenes_dict.get(id)
	elif not_preloaded.has(id):
		# load now
		scenes_dict[id] = ResourceLoader.load(not_preloaded[id])
		return scenes_dict.get(id)
	else:
		print_debug("Not scene with id: ", id)
		return null
