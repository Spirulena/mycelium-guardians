class_name MushroomNewMutationComponent extends ViewComponent

var chance: float = 0.1
@onready var rng: RandomNumberGenerator = RandomNumberGenerator.new()

var colors: Array = [
	'#b22d32', '#a28f44', '#92a441', '#7d955a', '#ac91d4', '#5a70a2', '#87271f', '#bb7dc1',
	'#a94021', '#7b9bcc', '#b19aa8', '#64862a', '#1b3b5c', '#804f57', '#b96c45', '#a98ad0', '#7d5243',
	'#6c1d33', '#7d5300', '#bf7c19', '#696a40', '#24be81', '#24ade2', '#5b6395', '#788c23', '#aaad1e',
	'#6a5200', '#748055', '#84221b', '#85b4a9', '#bfb4b9', '#9f69b8', '#b393de', '#99834a', '#756751',
	'#9aa4da', '#8187b5', '#bcb0b6', '#4f2c1e', '#772229', '#a94e58', '#7e8d31', '#ce8d78', '#632f55',
	'#ce6f14', '#a5a852', '#1d2d10'
]

func _ready() -> void:
	rng.seed = "MushroomNewMutationComponent".hash()
	pass

func handle_view_change(change: Dictionary):
	if super.handle_view_change(change):
		return
	pass

func pick_new_color() -> Color:
	# or
	var back: Color = colors.pop_back()
	colors.push_front(back)
	return back
	# bad recursion
	#var old_color: Color = Global.gene_base_color
	#var new: Color = colors.pick_random()
	#if new == old_color:
		#return pick_new_color()
	#else:
		#return new

func handle_model_change(change: Dictionary):
	if super.handle_model_change(change):
		return

	if change.type == ModelObject.Type.Building:
		if change.prev == null and change.curr != null:
			# New building
			# Ignore other then smog ?
			if change.curr.get_building_type() != BuildingObject.StructureType.Absorber_Smog:
				return
			# Focus on smog absorbers now.

			if get_mutation_occurance():


				var rarity:String = get_mutation_rarity()
				print_debug("GENE: We got %s mutation" % rarity)
				var b: BuildingObject = change.curr
				b.mutation = true
				b.mutation_id = "%s%s" % [char(rng.randi_range(65, 90)), char(rng.randi_range(65, 90))]
				# Up the generation counter
				# could have a)b) or something for different paths based of gen.1
				#b.base_generation += 1

				# Color
				b.base_color = pick_new_color()

				# randomized decay
				rng.randfn()
				b.mutation_decay_time_factor = rng.randf() # allow for negative vals
				b.base_decay_time = b.base_decay_time + b.base_decay_time * b.mutation_decay_time_factor

				# Randomize smog absorbtion,
				# 1st ustilize smog vars from BuildingObject in processing
				# use radiation as a factor for Gaussian , mean,
				# radiation would have to be more then just 0 or 1
				# maybe if we have radiation aka. 1 just increase mean a bit
				# later make it proportional to radiation
				var mean: float = 0.0
				var radiation = _lc.get_radiation(b.get_coords())
				if radiation > 0.0:
					mean = 0.2
				var smog_mutation = clampf(rng.randfn(mean, 1.0), -1, 1)
				b.mutation_smog_change_factor = smog_mutation
				b.base_smog_change = b.base_smog_change + b.base_smog_change * smog_mutation
				# Randomize growth time
				# now do switch
				# base_growth_speed_factor
				# Only sometimes
				if get_mutation_occurance():
					var growth_mutation = clampf(rng.randfn(mean, 1.0), -1, 1)
					# scale speed down
					growth_mutation = growth_mutation * 0.2
					b.mutation_growth_speed_factor = growth_mutation
					b.base_growth_speed_factor = b.base_growth_speed_factor + b.base_growth_speed_factor * growth_mutation

				# uncommon - smaller values
				# rare - bigger values

			# then mutate the below instance stats.
			# pass in the color, or call the color change if that is
			# change.curr

func check_do_we_mutate():
	var r: = rng.randfn(0.4, 1.2)
	print(r)
	pass # consider radiation for rng the mutation occurance

func get_mutation_occurance() -> bool:
	var random_float:float = rng.randf()

	if random_float < 0.8:
		# 80% chance of being returned.
		return false
	elif random_float < 0.95:
		# 15% chance of being returned.
		return true
	else:
		# 5% chance of being returned.
		return true

func get_mutation_rarity() -> String:
	var random_float:float = rng.randf()

	if random_float < 0.8:
		# 80% chance of being returned.
		return "Common"
	elif random_float < 0.95:
		# 15% chance of being returned.
		return "Uncommon"
	else:
		# 5% chance of being returned.
		return "Rare"
