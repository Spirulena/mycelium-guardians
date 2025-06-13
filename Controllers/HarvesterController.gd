class_name HarvesterController extends Node


var _model: HarvesterObject
var _lc: LevelController

func _init(model):
	_model = model
	_lc = LevelController.get_level_controller()

func _ready():
	name = "HarvesterController_%d_%d" % [_model.get_coords().x, _model.get_coords().y]

func _process(delta):
	_model.increase_time_in_state(delta)

	match _model.get_state():
		ModelObject.State.Removed:
			#print_debug("HarvesterController - _model in state Removed")
			set_process(false)
			# TODO: react to removed state in presenter.
			queue_free()
			return
		HarvesterObject.HarvesterState.Depleted:
			#print_debug("Harvester state: depleted, removing HarvesterObject")
			_lc.remove_object(_model)

		HarvesterObject.HarvesterState.Idle: # is idle == producing enzyme ?
			if _model.get_time_in_state() > _model.get_time_producing_enzyme():
				_model.set_state(HarvesterObject.HarvesterState.Harvesting)
		HarvesterObject.HarvesterState.Harvesting:
			# Is this above match, independent of a state ?
			if (_model.get_resource_object() == null or
				is_zero_approx(_model.get_resource_object().get_resource_amount()) ):
				#print_debug("resource null or amount == 0, changing state to depleted")
				_model.set_state(HarvesterObject.HarvesterState.Depleted)
				return

			var coords = _model.get_coords()
			# this needs to get coords of the ruin
			var tiles = _model.get_tile_coords()
			var ruin = _model._ruin
			if ruin != null:
				tiles = ruin.get_tile_coords()

			var extraction_rate = _lc.get_extraction_rate_at_coords(coords)
			var extraction_rate_per_tile = extraction_rate # make it faster with more tiles/ tiles.size()
			var total_extracted: float = 0
			for tile_coords in tiles:
				var tile = _lc.get_tile_at(tile_coords)
				var res_object = _model.get_resource_object()
				if tile and _model.get_resource_object().get_resource_amount() > 0:
					var actual_extraction = min(extraction_rate_per_tile, _model.get_resource_object().get_resource_amount())
					_model.get_resource_object().change_resource_amount(-actual_extraction)
					tile.change_tally(_model.get_resource_type(), actual_extraction)
					total_extracted += actual_extraction
					# save metadata so that ruin UI can display it
			_model.last_extracted_amount = total_extracted
			_model.accumulated_extraction += total_extracted
			# old extraction strait to colony tally
			#if (_model.get_resource_object() != null and
				#_model.get_resource_object().get_resource_amount() > 0):
				## now try just adding resource, ignore ball.
				## _lc.spawn_resource_ball_at(coords, _model.get_resource_type(), extraction_rate)
				#_model.get_resource_object().change_resource_amount(-extraction_rate)
				#_lc.change_tally(_model.get_resource_type(), extraction_rate)

			_model.set_state(HarvesterObject.HarvesterState.Idle)
