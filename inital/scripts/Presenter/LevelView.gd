class_name LevelView extends Node2D

@export var tile_map_ground_4x: TileMap
@export var tile_map_block_ground: TileMap
@export var level_editor_tilemap: TileMapLayer

const TILE_WIDTH :int = 256  # Adjust as per your tile's width
const TILE_HEIGHT :int = 128  # Adjust as per your tile's height

var components: Dictionary
# so tutorial can change the enable status then call super
var components_enable: Dictionary

var sfx: SfxPlayer
var level_controller: LevelController

var _iso_grid: TileMap
var game_ui_controller: GUIController

var ignore_view_change_type: Array
var ignore_model_change_type: Array


var wind

signal view_changed(change: Dictionary) # this will be filtered view_changed
signal model_changed(change: Dictionary) # this will be filtered view_changed

# TO REVIEW AND MOVE TO COMPONENTS
var mouse_controller

# END TO REVIEW AND MOVE TO COMPONENTS

func _init() -> void:
	# Can just assume default == true on missing entries,
	components_enable = {
		'HintsComponent': true,
		'GroundPresenterComponent': true,
		'TileDebugComponent': true,
		'EnzymesComponent': true,
		'WindControllerComponent': true,
		'SmogComponent': true,
		'ChanceControllerComponent': true,
		'CanBuildHereComponent': true,
		'StructurePlacingRadiusComponent': true,
		'BuildingComponent': true,
		'HarvesterComponent': true,
		'StorageAddedComponent': true,
		'RuinComponent': true,
		'ResourcesComponent': true,
		'CreaturesComponent': true,
		'PlantsComponent': true,
		'AIPanelComponent': false, # not touched in a while
		'MusicPlayerComponent': true,
		'PathsTimerComponent': true,
		'LevelCameraComponent': true,
		'HighlightComponent': true,
		'MyceliumPreviewComponent': true,
		'MyceliumComponent': true,
		'OverlaysViewComponent': true,
		'PlaceMyceliumPathDefaultComponent': true,
		'TileObjectComponent': true,
		'MushroomNewMutationComponent': false,
		'MyceliumExpandOnMushroomComponent': true,
		'ResourceFoundComponent': true,
	}
	components = {}

	ignore_view_change_type = []
	ignore_model_change_type = []

	level_controller = LevelController.get_level_controller()

func _ready() -> void:
	add_child(level_controller)

	# TODO: -> component
	# Move into component as well
	# access via components.get('SFXComponent')
	sfx = Loader.get_loader().return_scene("sfx_player").instantiate()
	add_child(sfx)

	# TODO: Component
	_iso_grid = TileMap.new()
	#_iso_grid.position = Vector2(-128, -64)
	_iso_grid.tile_set = TileSet.new()
	_iso_grid.tile_set.tile_shape = TileSet.TILE_SHAPE_ISOMETRIC
	_iso_grid.tile_set.tile_layout = TileSet.TILE_LAYOUT_DIAMOND_DOWN
	_iso_grid.tile_set.tile_offset_axis = TileSet.TILE_OFFSET_AXIS_HORIZONTAL
	_iso_grid.tile_set.tile_size = Vector2i(256, 128)
	add_child(_iso_grid)

	# Make it a component as well ?
	game_ui_controller = Loader.get_loader().return_scene("game_ui_scene").instantiate()
	game_ui_controller.set_iso_grid(_iso_grid)
	game_ui_controller.view_changed.connect(_on_view_changed)
	add_child(game_ui_controller)

	level_controller.model_changed.connect(_on_model_changed)

	## Components
	# OR add property to component.enabled or disable() to ViewComponent
	if components_enable['HintsComponent']:
		add_child(HintsComponent.new(level_controller, self, game_ui_controller, 'HintsComponent'))
	if components_enable['GroundPresenterComponent']:
		var args:Dictionary = {
			'tile_map': tile_map_ground_4x,
			'tile_map_block': tile_map_block_ground,
		}
		add_child(GroundPresenterComponent.new(level_controller, self, game_ui_controller, 'GroundPresenterComponent', args))
	if components_enable['TileDebugComponent']:
		add_child(TileDebugComponent.new(level_controller, self, game_ui_controller, 'TileDebugComponent'))
	if components_enable['SmogComponent']:
		add_child(SmogComponent.new(level_controller, self, game_ui_controller, 'SmogComponent'))
	if components_enable['EnzymesComponent']:
		add_child(EnzymesComponent.new(level_controller, self, game_ui_controller, 'EnzymesComponent'))
	if components_enable['WindControllerComponent']:
		add_child(WindControllerComponent.new(level_controller, self, game_ui_controller, 'WindControllerComponent'))
	if components_enable['ChanceControllerComponent']:
		add_child(ChanceControllerComponent.new(level_controller, self, game_ui_controller, 'ChanceControllerComponent'))
	if components_enable['CanBuildHereComponent']:
		add_child(CanBuildHereComponent.new(level_controller, self, game_ui_controller, 'CanBuildHereComponent'))
	if components_enable['StructurePlacingRadiusComponent']:
		add_child(StructurePlacingRadiusComponent.new(level_controller, self, game_ui_controller, 'StructurePlacingRadiusComponent'))
	if components_enable['BuildingComponent']:
		add_child(BuildingComponent.new(level_controller, self, game_ui_controller, 'BuildingComponent'))
	if components_enable['HarvesterComponent']:
		add_child(HarvesterComponent.new(level_controller, self, game_ui_controller, 'HarvesterComponent'))
	if components_enable['StorageAddedComponent']:
		add_child(StorageAddedComponent.new(level_controller, self, game_ui_controller, 'StorageAddedComponent'))
	if components_enable['RuinComponent']:
		add_child(RuinComponent.new(level_controller, self, game_ui_controller, 'RuinComponent'))
	if components_enable['ResourcesComponent']:
		add_child(ResourcesComponent.new(level_controller, self, game_ui_controller, 'ResourcesComponent'))
	if components_enable['CreaturesComponent']:
		add_child(CreaturesComponent.new(level_controller, self, game_ui_controller, 'CreaturesComponent'))
	if components_enable['PlantsComponent']:
		add_child(PlantsComponent.new(level_controller, self, game_ui_controller, 'PlantsComponent'))
	if components_enable['AIPanelComponent']:
		add_child(AIPanelComponent.new(level_controller, self, game_ui_controller, 'AIPanelComponent'))
	if components_enable['MusicPlayerComponent']:
		add_child(MusicPlayerComponent.new(level_controller, self, game_ui_controller, 'MusicPlayerComponent'))
	if components_enable['PathsTimerComponent']:
		add_child(PathsTimerComponent.new(level_controller, self, game_ui_controller, 'PathsTimerComponent'))
	if components_enable['LevelCameraComponent']:
		add_child(LevelCameraComponent.new(level_controller, self, game_ui_controller, 'LevelCameraComponent'))
	if components_enable['HighlightComponent']:
		add_child(HighlightComponent.new(level_controller, self, game_ui_controller, 'HighlightComponent'))
	if components_enable['MyceliumPreviewComponent']:
		add_child(MyceliumPreviewComponent.new(level_controller, self, game_ui_controller, 'MyceliumPreviewComponent'))
	if components_enable['MyceliumComponent']:
		add_child(MyceliumComponent.new(level_controller, self, game_ui_controller, 'MyceliumComponent'))
	if components_enable['OverlaysViewComponent']:
		add_child(OverlaysViewComponent.new(level_controller, self, game_ui_controller, 'OverlaysViewComponent'))
	if components_enable['PlaceMyceliumPathDefaultComponent']:
		add_child(PlaceMyceliumPathDefaultComponent.new(level_controller, self, game_ui_controller, 'PlaceMyceliumPathDefaultComponent'))
	if components_enable['TileObjectComponent']:
		add_child(TileObjectComponent.new(level_controller, self, game_ui_controller, 'TileObjectComponent'))
	if components_enable['MushroomNewMutationComponent']:
		add_child(MushroomNewMutationComponent.new(level_controller, self, game_ui_controller, 'MushroomNewMutationComponent'))
	if components_enable['MyceliumExpandOnMushroomComponent']:
		add_child(MyceliumExpandOnMushroomComponent.new(level_controller, self, game_ui_controller, 'MyceliumExpandOnMushroomComponent'))
	if components_enable['ResourceFoundComponent']:
		add_child(ResourceFoundComponent.new(level_controller, self, game_ui_controller, 'ResourceFoundComponent'))

# MyceliumExpandOnMushroomComponent
	# TMP:
	AudioServer.set_bus_mute(AudioServer.get_bus_index("ff_crasher"), true)
	# TODO: fix this, check if exist or fill in for rest of the level
	if level_editor_tilemap != null and is_instance_valid(level_editor_tilemap):
		level_editor_tilemap.hide()

func _on_model_changed(change: Dictionary):
	# Filter events, so we can ignore some
	# View components have it's own view, model change ignores
	if change.type in ignore_model_change_type:
		print_debug("Ignoring model change.type == ", change.type)
		return
	model_changed.emit(change)

func _on_view_changed(change: Dictionary) -> void:
	# Filter events, so we can ignore some
	if change.type in ignore_view_change_type:
		print_debug("Ignoring view change.type == ", change.type)
		return
	view_changed.emit(change)

## Helpers

func play_sound(sound: SfxPlayer.SFX) -> void:
	sfx.play_sfx_type(sound)

func to_position(coords: Vector2i) -> Vector2:
	return to_pixel_position(coords)
	# Note: Godot 4.3 will not need instance of tile map to translate positions
	# return _iso_grid.map_to_local(coords)

func to_pixel_position(grid_position: Vector2i) -> Vector2:
	return Vector2(
		(grid_position.x - grid_position.y) * TILE_WIDTH / 2.0 + 128,
		(grid_position.x + grid_position.y) * TILE_HEIGHT / 2.0 + 64
	)

## Components
func register_component(key: String, component: Node) -> void:
	components[key] = component

## Ignore changes
# Could move to ViewComponent ?, would use _view.components
# View
func add_component_view_ignore(key: String, ignore: Array) -> bool:
	if not components.has(key):
		print_debug("No component: ", key)
		return false
	if not components[key].has_method("add_view_ignore"):
		print_debug("No method add_view_ingore in : ", key)
		return false
	components[key].add_view_ignore(ignore)
	return true

func del_component_view_ignore(key: String, ignore: Array) -> bool:
	if not components.has(key):
		print_debug("No component: ", key)
		return false
	if not components[key].has_method("del_view_ignore"):
		print_debug("No method add_view_ingore in : ", key)
		return false
	components[key].del_view_ignore(ignore)
	return true

# Model
func add_component_model_ignore(key: String, ignore: Array) -> bool:
	if not components.has(key):
		print_debug("No component: ", key)
		return false
	if not components[key].has_method("add_model_ignore"):
		print_debug("No method add_model_ingore in : ", key)
		return false
	components[key].add_model_ignore(ignore)
	return true
