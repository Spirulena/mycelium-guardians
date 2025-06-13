class_name TileObjectComponent extends ViewComponent

var smog_tile_map: TileMapLayer
var radiation_tile_map: TileMapLayer
var playable_tile_map: TileMapLayer

var smog_level_data: Dictionary
var smog_level_rows: Dictionary
var smog_cells: Array[Vector2i]

var radiation_cells: Array[Vector2i]
var radiation_level_data: Dictionary

var playable_cells: Array[Vector2i]
var playable_level_data: Dictionary

func _ready() -> void:
	smog_level_data = {}
	radiation_level_data = {}
	playable_level_data = {}

	if _le == null:
		# for old sandbox level and prologue
		print_debug("Level Editor TileMaps Not set")
		return
	# load smog from level editor
	smog_tile_map = _le.get_node('Smog')
	if not is_instance_valid(smog_tile_map):
		print_debug('Smog time map is not a valid node')
	else:
		# read
		smog_cells = smog_tile_map.get_used_cells()
		for coords in smog_cells:
			if not smog_level_rows.has(coords.y):
				smog_level_rows[coords.y] = {}
			smog_level_rows[coords.y][coords.x] = 1
			smog_level_data[coords] = 1 # defaults to 1
			# could read from tile map, f.ex based on tile index or data
	# TODO: make it react to smog event, then load the smog from level data ?

	radiation_tile_map = _le.get_node('Radiation')
	if not is_instance_valid(radiation_tile_map):
		print_debug('Radiation time map is not a valid node')
	else:
		radiation_cells = radiation_tile_map.get_used_cells()
		for coords in radiation_cells:
			radiation_level_data[coords] = 1

	playable_tile_map = _le.get_node('PlayableArea')
	if not is_instance_valid(playable_tile_map):
		print_debug('playable_tile_map is not a valid node')
	else:
		playable_cells = playable_tile_map.get_used_cells()
		for coords in playable_cells:
			playable_level_data[coords] = true
			# get tile Object
			_lc.get_tile_at.call_deferred(coords)

	#get_tree().create_timer(5).timeout.connect(set_smog_from_level_editor)

# Formula calc
# [[x, 3*(1/(x+0.4)-1)] for x in [0.99, 1.0, 0.9, 0.8, 0.7, 0.6, 0.5, 0.4, 0.3, 0.2, 0.1, 0.09, 0.05, 0.01, 0.001, 0]]
#[[0.99, -0.8417266187050361],
 #[1.0, -0.8571428571428571],
 #[0.9, -0.6923076923076925],
 #[0.8, -0.5000000000000002],
 #[0.7, -0.2727272727272728],
 #[0.6, 0.0],
 #[0.5, 0.3333333333333335],
 #[0.4, 0.75],
 #[0.3, 1.2857142857142858],
 #[0.2, 1.9999999999999996],
 #[0.1, 3.0],
 #[0.09, 3.122448979591837],
 #[0.05, 3.666666666666667],
 #[0.01, 4.317073170731707],
 #[0.001, 4.481296758104737],
 #[0, 4.5]]

var smog_avg_last: float
func get_smog_avg_last()->float:
	return smog_avg_last

## Returns temperature increase
func get_smog_on_playable_area() -> float:
	var epsilon: float = 0.4
	var smog_amount: float
	var smog_tiles_sum: int
	var max_temperature_increase: float = 4.0
	var smog_avg: float

	for coords in playable_cells:
		if smog_level_data.has(coords): # limit to only places were we have smog in level editor
			# could just check all TBH
			smog_amount += clampf(_lc.get_tile_at(coords).get_smog(), 0.0, 1.0)
			smog_tiles_sum += 1
	if smog_tiles_sum == 0:
		# no smog tiles
		return 0
	smog_avg = smog_amount / float(smog_tiles_sum)
	smog_avg = clampf(smog_avg, 0, 1.0)
	smog_avg_last = smog_avg
	#print_debug("Smog amount: %f, amount: %d, avg: %f" % [smog_amount, smog_tiles_sum, smog_avg])
	var temperature_increase: float = 0.0
	temperature_increase = 3 * (1.0/(smog_avg + epsilon)-1)
	temperature_increase = min(temperature_increase, max_temperature_increase)
	#print_debug("Temperature increase: %f" % temperature_increase)
	return temperature_increase

func set_smog_from_level_editor():
	if not _lc.get_config('smog_use_level_editor'):
		return
	get_smog_on_playable_area()
	# Here we can calculate what are the smog levels ? before re-setting ?
	# and also on timer

	var i: int = 0
	var end = smog_level_rows.keys().size()
	var keys = smog_level_rows.keys().duplicate()
	keys.sort()
	#keys.reverse()
	for rr in range(end):
		set_smog_row(keys[i], i) # .call_deferred(rr, i)
		print(keys[i], smog_level_rows[keys[i]].keys())
		i += 1
		#print(i, min + i)

	#for coords in playable_cells:
		## Read from level editor, see block in MyceliumBlock thing
		#if smog_level_data.has(coords):
			#_lc.get_tile_at(coords).set_smog(smog_level_data[coords])
			# set amount

func set_smog_row(y: int, delay: int):
	# make 0.4 a float resource, add new file of that resource, save in level so we can change it at run time
	await get_tree().create_timer(float(delay)*0.4).timeout
	for x in smog_level_rows[y].keys():
		#_lc.get_tile_at(Vector2i(x, y)).set_smog(smog_level_data[Vector2i(x, y)])
		_lc.get_tile_at(Vector2i(x, y)).set_smog(1)
	# set all in one go
	# trigger this function with delay


func handle_model_change(change: Dictionary):
	if super.handle_model_change(change):
		return

	# new tile
	if change.type == 'TileObject' and change.curr  != null:
		# Legacy
		if not _lc.get_config('radiation_use_level_editor'):
			# Set radiation besed on noise
			change.curr.set_radiation(_lc.level_data.get_radiation_scaled(change.coords))
		if not _lc.get_config('smog_use_level_editor'):
			# smog base + noise
			change.curr.set_smog(_lc.level_data.get_smog_scaled(change.coords))

		# From level editor

		# RADIATION_LEVEL_EDITOR
		if _lc.get_config('radiation_use_level_editor'):
			# Read from level editor, see block in MyceliumBlock thing
			if radiation_level_data.has(change.coords):
				change.curr.set_radiation(radiation_level_data[change.coords])

		## SMOG_LEVEL_EDITOR
		#if _lc.get_config('smog_use_level_editor'):
			## Read from level editor, see block in MyceliumBlock thing
			#if smog_level_data.has(change.coords):
				#change.curr.set_smog(smog_level_data[change.coords])
