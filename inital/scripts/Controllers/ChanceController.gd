class_name ChanceController extends Node
## Used to caluclate chances for spawning plants and worms, now just allows grass to spawn
## when conditions are suitable
## @deprecated

var _level_controller: LevelController
var ticks

func _init():
	ticks = {
		'Plants': {
			'interval': 10 * 1000, #
			'last_call': Time.get_ticks_msec(),
			'function': process_plants_tick,
		},
	}
	# Note: Pass level controller in init from Main ?
	_level_controller = LevelController.get_level_controller()
	_level_controller.model_changed.connect(_model_changed)
	name = "ChanceController"

## Handler of [signal LevelController.model_changed]
func _model_changed(change):
	pass

# Why not just a timer objects ?
func _process(delta):
	for key in ticks.keys():
		if tick_run(key, Time.get_ticks_msec()):
			ticks[key].function.call(delta)

func tick_run(key, msec_now) -> bool:
	var check = ticks[key].last_call + ticks[key].interval < msec_now
	if check:
		ticks[key].last_call = msec_now
	return check

func process_plants_tick(delta):
	if not is_instance_valid(_level_controller):
		return
	process_plants_tick_grass(delta)

func process_plants_tick_grass(delta):
	if not is_instance_valid(_level_controller):
		return
	var all_tiles = _level_controller.get_all_tiles()
	#all_tiles.shuffle()

	for coords in all_tiles:
		var tile: TileObject = _level_controller.get_tile_at(coords)
		if tile.is_suitable_for_grass():
			_level_controller.add_object_guarded(PlantObject.new(coords, PlantObject.PlantType.DryGrass, 100))
			#return # to prevent too much at once, temporary
