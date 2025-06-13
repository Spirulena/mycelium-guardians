class_name FFCrasherStateBackAndForth extends FFCrasherState

var _model: MovableObject
var _destination
var _start_position
var _end_position
var _lc: LevelController

func _init(model, destination):
	_model = model
	_start_position = _model.get_coords()
	_end_position = _start_position + destination
	_destination = _start_position + destination #Vector2i(0, 0)
	_lc = LevelController.get_level_controller()

func get_next():
	#print("Calling get_next")
	# check if anything is in front.

	var coords = _model.get_coords()

	if coords == _destination:
		# Reverse the destination and start
		if _destination == _end_position:
			_destination = _start_position
		else:
			_destination = _end_position

	var d = _destination - coords
	# Directly use the sign function to get -1, 0, or 1
	d.x = sign(d.x)
	d.y = sign(d.y)

	# check new direction in one tile does it have any buildings in front.
	var tiles = _model.get_tile_coords()
	var next_tiles = []
	for t in tiles:
		next_tiles.append(t + d)
	#print(next_tiles)
	# now check next_tiles for buildings.
	var any_structure_ahead = false
	for n in next_tiles:
		var tile: = _lc.get_tile_at(n)
		if tile.get_structure() != null:
			# Check if structure is grown fully,
			# if not destroy it.
			# if already grown, then stop or change direction
			any_structure_ahead = true
			#print_debug("FF: Tile ", tile.get_coords(), " have structure in front of FF")
			break
		# ruin_ahead, should not self explode but avoid or move back.
		if tile.get_ruin() != null:
			any_structure_ahead = true
			#print_debug("FF: Ruin Ahead")
			break

	if any_structure_ahead:
		# Bump into opposite direction ?
		# Reverse the vector.

		# count as bump
		# see if it is z or Y bump.
		# Add horizontal, bump++
		# add vertical bump

		#if bumped more then 8 times. Stop the animation.
		# Scare with some Light flash, call for help. flare.

		#print_debug("FF: Stopping")
		# what now ?
		return {
			"direction": Vector2i.ZERO,
			"state": FFCrasherStateSignalObstacle.new(_model, _destination),
		}
		# New state ? Destroy, Blocked, Panic ?

	return {
		"direction": d,
		"state": self,
	}
