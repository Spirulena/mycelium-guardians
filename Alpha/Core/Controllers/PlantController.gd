class_name PlantController extends Node

var _model: PlantObject
var smog_on_growth_start
var _lc: LevelController
var _timer: Timer

func _init(model):
	_lc = LevelController.get_level_controller()
	_model = model
	_model.state_changed.connect(_state_changed)
	smog_on_growth_start = 0

func _ready():
	_timer = Timer.new()
	_timer.wait_time = 1
	_timer.autostart = true
	_timer.name = "Tick"
	_timer.timeout.connect(_on_timer_timeout)
	add_child(_timer)
	name = "PlantController_%d_%d" % [_model.get_coords().x, _model.get_coords().y]
	smog_on_growth_start = _lc.get_tile_at(_model.get_coords()).get_smog()

func _on_timer_timeout():
	update_plant_production()

func update_plant_production():
	var tile: TileObject = _lc.get_tile_at(_model.get_coords())
	if tile.can_consume_resources(_model.water_consumption_rate, _model.minerals_consumption_rate) and _lc.can_consume_resources(_model.water_consumption_rate, _model.minerals_consumption_rate):
		tile.consume_resources(_model.water_consumption_rate, _model.minerals_consumption_rate) # From tile

		var smog_level = tile.get_smog()  # Assume get_smog() returns the smog level at the tile
		var smog_data: Dictionary = calculate_smog_impact_and_penalty(smog_level)
		_model.smog_penalty_percent = smog_data["penalty_percent"]

		var smog_impact_factor = calculate_smog_impact_factor(smog_level)  # Calculate the impact of smog on carbon production

		# Adjust carbon production based on smog impact
		var adjusted_carbon_production = _model.base_carbon_production_rate * smog_data["impact"]

		# Now add this carbon directly to the tile's tally instead of the plant model
		tile.change_tally(ResourceObject.ResourceType.Carbon, adjusted_carbon_production)

		# Accumulate adjusted carbon production
		#_model.accumulate_carbon(adjusted_carbon_production)
		# TODO: move carbon to tile.
		# to a limit of how much tile can hold
	else:
		# Optional: Handle cases where there isn't enough water or minerals for the plant
		pass

func calculate_smog_impact_factor(smog_level: float) -> float:
	# Define how smog impacts carbon production. This example linearly decreases production from no impact at smog level 1 to 50% reduction at smog level 10.
	var impact = lerp(1.0, 0.5, (smog_level - 1) / 9)  # Linear interpolation from 100% to 50% efficiency
	return impact

func calculate_smog_impact_and_penalty(smog_level: float) -> Dictionary:
	# Ensure smog_level is clamped between 0 and 10 to avoid unexpected values
	smog_level = clamp(smog_level, 0, 10)
	# Adjust the impact calculation for smog levels starting from 0
	var impact = lerp(1.0, 0.5, smog_level / 10.0)  # Adjusted to divide by 10 directly for 0-10 range
	# Penalty percentage reflects the reduction from maximum efficiency
	var penalty_percent = (1.0 - impact) * 100  # Remains the same, correctly calculates based on adjusted impact
	return {"impact": impact, "penalty_percent": penalty_percent}


func _process(delta):
	_model.increase_time_in_state(delta)

	match _model.get_state():
		PlantObject.PlantState.Growing:
			# use get_time_in_state
			pass
		ModelObject.State.Removed:
			pass
		PlantObject.PlantState.Crashed:
			pass

func _state_changed(change):
	#if change.curr == ModelObject.State.Removed:
		#queue_free()

	# Crashed
	# Is this same as growing in smog ?
	if change.curr == PlantObject.PlantState.Crashed and change.prev != PlantObject.PlantState.Crashed :
		#print_debug(change)
		# Connect it to Plant ? _resources
		# add resource
		var res_amount = 5
		if smog_on_growth_start <= 0:
			res_amount += 20 # it was growing without smog
			# TODO: make it calculated per life of plant. add per tick produce * smog
		var r = ResourceObject.new(_model.get_coords(), ResourceObject.ResourceType.Carbon, res_amount)
		_lc.add_object(r)
		# add harvester
		var h = HarvesterObject.new(_model.get_coords())
		h.state_changed.connect(_harvester_state_changed)
		_lc.add_object_guarded(
			# Change, to just coords, resource would be added at tileObject level
			h
		)
		#_lc.harvest_from_coords(_model.get_coords())
	if change.curr != change.prev and change.curr == ModelObject.State.Removed:
		# based on time in state, get some carbon out, and some minerals, and tiny bit of water ?
		# or based on plant size get some carbon out
		var tile: TileObject = _lc.get_tile_at(_model.get_coords())
		tile.change_tally(ResourceObject.ResourceType.Carbon, +2)
		queue_free()

func _harvester_state_changed(change):
	if change.curr != change.prev and change.curr == HarvesterObject.HarvesterState.Depleted:
		_lc.remove_object(_model)
