class_name SmogAbsorberController extends Node

var _lc: LevelController
var _smog_absorber: BuildingObject
var _model: BuildingObject
var timer: Timer

func _init(model, lc):
	_lc = lc
	_smog_absorber = model
	_model = model

func _ready():
	_smog_absorber.state_changed.connect(_on_state_changed)
	name = "SmogAbsorberController_%d_%d" % [_smog_absorber.get_coords().x, _smog_absorber.get_coords().y]
	# for continous absorbtion
	timer = Timer.new()
	timer.wait_time = 1.0  # Set the timer to tick every second
	timer.autostart = false
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	_model.view_changed.connect(_on_view_changed)

func _on_view_changed(change):
	if change.type == 'UI' and change.prop == 'production':
		if change.curr == true:
			activate_absorber()
		elif change.curr == false:
			deactivate_absorber()

func _on_timer_timeout():
	apply_production()

# TODO: that is way to much code for something like that
# Make for the amount of smog reduced, get some minerals,
# Fixed per sec. based on Gene level or something. or DPS stat
func apply_production():
	# SMOG_EVENT:
	for coords in _model.process_coords:
		_lc.change_smog(coords, -(_model.base_smog_change))

func _on_state_changed(change):
	if change.prop == 'state':
		if change.curr == BuildingObject.BuildingState.Done:
			activate_absorber()
		elif change.curr == ModelObject.State.Removed:
			deactivate_absorber()
		elif change.curr == ModelObject.State.Upgrading:
			deactivate_absorber()

func activate_absorber():
	_model.processing_coords_amount = 0
	_model.process_coords.clear()

	var affected_tiles = _smog_absorber.get_smog_absorption_coords()  # This should return a list of tile coordinates
	for coords in affected_tiles:
		var can_process: bool = _lc.get_smog(coords) > 0.0
		if can_process:
			_model.process_coords.append(coords)
			_model.processing_coords_amount += 1

	_model.set_production_active(true)
	timer.start()

func deactivate_absorber():
	timer.stop()
	_model.set_production_active(false)
