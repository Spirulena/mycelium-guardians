class_name RadiationAbsorberController extends Node

var _lc: LevelController
var _model: BuildingObject
var timer: Timer

func _init(model, lc):
	_lc = lc
	_model = model
	_model.processing_coords_amount = 0
	_model.process_coords = []
	_model.energy_consumption = 0.01

@onready var tiles_to_distribute

func _ready():
	_model.state_changed.connect(_on_state_changed)
	name = "RadiationAbsorberController_%d_%d" % [_model.get_coords().x, _model.get_coords().y]
	# for continous absorbtion
	timer = Timer.new()
	timer.wait_time = 1.0  # Set the timer to tick every second
	timer.autostart = false
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	_model.view_changed.connect(_on_view_changed)
	tiles_to_distribute = _lc.get_coords_in_circle(_model.get_coords(), 2)

func _on_view_changed(change):
	if change.type == 'UI' and change.prop == 'production':
		if change.curr == true:
			activate_absorber()
		elif change.curr == false:
			deactivate_absorber()

func _on_timer_timeout():
	# This function replaces the continuous operation logic in _process
	apply_production()

func apply_production():
	var tiles:int = _model.process_coords.size()
	if tiles < 1:
		return

	var energy_available: float = _lc.get_energy()
	var minerals_available: float = _lc.get_minerals()
	if minerals_available <= 0:
		# can keep track of how many times that happened.
		# or last time, and if above threshould, pause animation ?
		return

	var enzymes_available: float = _lc.get_enzymes_amount()

	# Define the consumption rates per tick
	var energy_consumption_per_tile: float = 0.001
	var mineral_consumption_per_tile: float = 0.0001
	var enzyme_consumption_per_tile: float = 0.0053
	var energy_output_per_tile: float = 0.021

	# Calculate efficiency based on available resources
	var efficiency_ratio: float = calculate_efficiency(tiles, energy_available, enzymes_available, energy_consumption_per_tile, enzyme_consumption_per_tile)

	# Initialize counters for total input consumption and output production
	var total_energy_input: float = 0
	var total_mineral_input: float = 0
	var total_enzymes_consumed: float = 0
	var total_energy_output: float = 0

	for coords in _model.process_coords:
		# Calculate the input consumption and output production for this tile based on efficiency
		var tile_energy_input: float = energy_consumption_per_tile * efficiency_ratio
		var tile_mineral_input: float = mineral_consumption_per_tile * efficiency_ratio
		var tile_enzyme_consumed: float = enzyme_consumption_per_tile * efficiency_ratio
		var tile_energy_output: float = energy_output_per_tile * efficiency_ratio

		# Check if there are enough resources (energy, enzymes, and minerals) to process this tile
		if enzymes_available >= tile_enzyme_consumed and minerals_available >= tile_mineral_input:
			 # Update totals based on efficiency
			total_energy_input += tile_energy_input
			total_mineral_input += tile_mineral_input
			total_enzymes_consumed += tile_enzyme_consumed
			total_energy_output += tile_energy_output

			# Deduct from available resources
			energy_available -= tile_energy_input
			# NOTE: energy_output is not applied, so might happen that it could process but won't
			energy_available += tile_energy_output
			minerals_available -= tile_mineral_input
			enzymes_available -= tile_enzyme_consumed
		else:
			break # Stop processing if resources are insufficient

	# Cap the energy output based on storage space
	var energy_limit = _lc.get_tally_storage_limit(ResourceObject.ResourceType.Energy)
	var energy = _lc.get_energy()
	var available_storage_space = energy_limit - energy
	#total_energy_output = min(total_energy_output, available_storage_space)
	var reminder: float = available_storage_space - total_energy_output
	if reminder < 0:
		var to_distribute = total_energy_output - available_storage_space
		#var tiles_to_distribute = _lc.get_coords_in_circle(_model.get_coords(), 3)
		distribute_energy_to_tiles(tiles_to_distribute, to_distribute)
	else:
		# add to colony
		var to_colony: float = max(0, available_storage_space)
		_lc.change_energy(+to_colony)  # Produce energy to colony

	# Apply resource changes
	_lc.change_energy(-total_energy_input)  # Consume energy
	_lc.change_minerals(-total_mineral_input)  # Consume minerals
	_lc.change_enzymes_amount(-total_enzymes_consumed)


	# Update model's last input and output records
	_model.last_energy_input = total_energy_input
	_model.last_minerals_input = total_mineral_input
	_model.last_enzymes_consumed = total_enzymes_consumed
	_model.last_energy_output = total_energy_output

func distribute_energy_to_tiles(affected_tiles: Array, total_energy_output: float):
	var energy_per_tile = total_energy_output / affected_tiles.size()

	for coords in affected_tiles:
		var tile = _lc.get_tile_at(coords)
		if tile:
			var tile_energy_current = tile.get_tally(ResourceObject.ResourceType.Energy)
			var tile_energy_max = tile.get_max_tile_storage(ResourceObject.ResourceType.Energy) + 2.0
			var tile_energy_available_space = tile_energy_max - tile_energy_current

			var energy_to_tile = min(energy_per_tile, tile_energy_available_space)
			tile.change_tally(ResourceObject.ResourceType.Energy, energy_to_tile)

func calculate_efficiency(tiles: int, energy_available: float, enzymes_available: float, energy_consumption: float, enzyme_consumption_per_tile: float) -> float:
	var base_efficiency_energy: float = min(energy_available / (energy_consumption * tiles), 1.0)
	var base_efficiency_enzymes: float = min(enzymes_available / (enzyme_consumption_per_tile * tiles), 1.0)
	var efficiency_ratio: float = min(base_efficiency_energy, base_efficiency_enzymes)  # Use the lower of the two efficiencies
	return max(0.5, efficiency_ratio)

func apply_continuous_smog_absorption_effects():
	var energy_available = _lc.get_energy()
	var efficiency_ratio = max(0, min(energy_available / _model.energy_consumption, 1.0))

	# Assuming smog_absorber.smog_extraction_rate is the amount absorbed per second
	var total_smog_absorbed = 0

	for coords in _model.get_smog_absorption_coords():
		var smog_level = _lc.get_smog(coords)
		var actual_absorption = min(smog_level, _model.smog_extraction_rate * efficiency_ratio)
		_lc.change_smog(coords, -actual_absorption)
		total_smog_absorbed += actual_absorption

	# Adjust energy based on actual operation
	_lc.change_energy(-_model.energy_consumption * efficiency_ratio)

func _on_state_changed(change):
	if change.prop == 'state':
		if change.curr == BuildingObject.BuildingState.Done:
			activate_absorber()
		elif change.curr == ModelObject.State.Removed:
			deactivate_absorber()

func activate_absorber():
	_model.processing_coords_amount = 0
	_model.process_coords.clear()

	for coords in _model.get_radiation_absorption_coords():
		var can_process: bool = _lc.get_radiation(coords) >= 1
		if can_process:
			_model.process_coords.append(coords)
			_model.processing_coords_amount += 1
			_lc.change_radiation(coords, -1)
	_model.set_production_active(true)
	timer.start()

func deactivate_absorber():
	for coords in _model.process_coords:
		_lc.change_radiation(coords, +1)
	_model.set_production_active(false)
	timer.stop()
