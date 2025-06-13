class_name Elements01 extends LevelView

@onready var camera_component: LevelCameraComponent
@onready var block_mycelium_layer:TileMapLayer
@onready var allowed_mycelium_layer:TileMapLayer
@onready var tile_object_component: TileObjectComponent

@export_category("Smog emitter")
@export var smog_progress_bar: ProgressBar
@export_category("Temperature")
@export var ambient_temp_label: Label
@export var temperature_smog_increase: ProgressBar
@export var progress_bar_max: int = 100
@export_category("Smog")
@export var smog_avg_label: Label
@export_category("Melting point")
@export var melting_label: Label # its more top level control to hide / show
@export var melting_progress: ProgressBar
@export var melting_target: int = 60

@export_category("Pipes")
@export var smog_particles_container: Node2D

# Genes,
# growth_speed: float
# smog_speed: float
# decay_speed: float
# then modifiers list
# growth_speed_mods: Array[float]
# functions
# genes.get_growth_speed() -> float (will apply all the speed mods to base and return result). set this on new absorbers.

# Card:
# Stat: growth time:  (param)
# Mod: (-)10%    : (direction)(amount)
# Applies to: All mushrooms (target)

# Card:
# Stat: Smog absorbtion speed      | can only apply to smog absorber, for now special case.
# Mod: +10%                        | (direction) (amount: float 0-1, or int(0-100)), or just (-0.2 <-> 0.2)| 5,10,15,20%, lucky(50%)
# Applies to: Smog absorber only   | s

# chose 1 of 3, or Skip(keep mutating), more radiation, more mutation ? in localized radiation zones ?
# maltadaptive, adaptive. gene, (new color) !
# New mutation, do you want to keep it ?
# then slice genes, or
# Like color, grow this variaty to improve other stats.

# Radiation occurs randomly then we just keep them or not ?

# prototype worm spawning here.
# them move to component.
# use timer, or when got the organic matter.

var list_emitters: Array[GPUParticles2D]
func vfx_get_smog_emitters():
	for child in smog_particles_container.get_children(true):
		if child is Marker2D:
			var gpu: GPUParticles2D = child.get_child(0)
			if is_instance_valid(gpu):
				if not list_emitters.has(gpu):
					list_emitters.append(gpu)

func vfx_stop_smog_emitters():
	for emitter in list_emitters:
		emitter.emitting = false

func vfx_emit_smog():
	for emitter in list_emitters:
		emitter.emitting = true
	get_tree().create_timer(5).timeout.connect(vfx_stop_smog_emitters)

func _ready() -> void:
	temperature_smog_increase.max_value = progress_bar_max
	melting_progress.max_value = melting_target

	block_mycelium_layer = level_editor_tilemap.get_node("BlockMycelium")
	allowed_mycelium_layer = level_editor_tilemap.get_node("AllowedMycelium")
# Intercept Mycelium add from GUI ?
# and filter here so that can be in component
	components_enable['HintsComponent'] = false
	components_enable['TileDebugComponent'] = true
	components_enable['PlaceMyceliumPathDefaultComponent'] = true
	components_enable['GroundPresenterComponent'] = false
	components_enable['TileObjectComponent'] = true
	components_enable['ChanceControllerComponent'] = true
	components_enable['MushroomNewMutationComponent'] = true
	components_enable['MyceliumExpandOnMushroomComponent'] = true
	components_enable['ResourceFoundComponent'] = true

	level_controller.level_data._tally[ResourceObject.ResourceType.Water] = [300, 600]
	level_controller.level_data._tally[ResourceObject.ResourceType.Energy] = [300, 600]
	level_controller.level_data._tally[ResourceObject.ResourceType.Minerals] = [300, 600]
	level_controller.level_data._tally[ResourceObject.ResourceType.Carbon] = [300, 600]
	level_controller.level_data._tally[ResourceObject.ResourceType.Enzymes] = [100, 200]

	# change Ground Presenter
	# separate FoW from Ground below
	# add component for CreatureLoader / Placer

	# Turn of mycelium extraction
	# move to set_config ? Level Config rather then  global
	Global.settings['mycelium']['process_resource_extraction'] = false
	Global.settings['mycelium']['process_water'] = false

	# add the same for Smog
	# SMOG_LEVEL_EDITOR
	level_controller.set_config('smog_use_level_editor', true)
	level_controller.set_config('radiation_use_level_editor', true)
	super()

	level_controller.auto_expand_mycelium_towards_water = false
	level_controller.set_ignore_water_noise(true)


	load_level()
	components.get('PlaceMyceliumPathDefaultComponent').setup() # pass
	components.get('MusicPlayerComponent').music.start_random_chords()
	tile_object_component = components.get('TileObjectComponent')
	# Limit the camera for now
	camera_component = components.get("LevelCameraComponent")
	camera_component.camera2d.zoom = Vector2(1, 1)
	camera_component.camera2d.position = Vector2(level_controller.get_base_coords()[0])
	camera_component.camera2d.limit_left = -9000
	camera_component.camera2d.limit_right = 9000
	camera_component.camera2d.limit_top = -4250
	camera_component.camera2d.limit_bottom = 4250
	camera_component.move_to_base()

	# Smog Event
	smog_emit_timer = Timer.new()
	smog_emit_timer.autostart = false
	smog_emit_timer.wait_time = 60
	smog_emit_timer.timeout.connect(reset_smog)
	add_child(smog_emit_timer)

	# Smog stats collection / 2s
	smog_temp_calc_timer = Timer.new()
	smog_temp_calc_timer.autostart = false
	smog_temp_calc_timer.wait_time = 2
	smog_temp_calc_timer.timeout.connect(adjust_temperature_based_on_smog)
	add_child(smog_temp_calc_timer)

	vfx_get_smog_emitters()
	vfx_stop_smog_emitters()

	# Initial timer for Smog Event
	get_tree().create_timer(1).timeout.connect(func(): vfx_emit_smog(); tile_object_component.set_smog_from_level_editor(); start_smog_loop(); smog_temp_calc_timer.start())
	var progress_bar_tween: Tween = get_tree().create_tween()
	progress_bar_tween.tween_property(smog_progress_bar, "value", 100, 1).from(70).set_trans(Tween.TRANS_LINEAR)
	# TODO: timer that will run smog on loop until the power is cut off from the source.
	vfx_stop_smog_emitters()

func re_enable_water():
	# This didn't worked, check why,, ach, false -> true would do the trick
	# but just use water from tile map, and make sure that
	Global.settings['mycelium']['process_resource_extraction'] = true
	Global.settings['mycelium']['process_water'] = true
	level_controller.auto_expand_mycelium_towards_water = false
	level_controller.set_ignore_water_noise(false)

func update_smog_avg_label():
	smog_avg_label.text = "Smog avg: %0.3f" % tile_object_component.get_smog_avg_last()

var smog_temp_calc_timer: Timer
var tick_adjustement: float
var temperature_goal_reached: bool = false
var melting_goal_reached: bool = false

func adjust_temperature_based_on_smog():
	temperature_smog_increase.max_value = progress_bar_max
	tick_adjustement = tile_object_component.get_smog_on_playable_area()

	update_smog_avg_label()
	var bar_val = temperature_smog_increase.value
	var new_val = bar_val + tick_adjustement
	new_val = clampf(new_val, 0, progress_bar_max) # if negative temp adjustmenet, don't go below 0

	var bar_tween: Tween = get_tree().create_tween()
	bar_tween.tween_property(temperature_smog_increase, "value", new_val, 1.29).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)

	if is_equal_approx(new_val, progress_bar_max):
		print_debug("Got the temperature goal")
		if temperature_goal_reached == false:
			temperature_goal_reached = true
			melting_label.visible = true
	else:
		temperature_goal_reached = false


	if temperature_goal_reached:
		var new_melt_val = melting_progress.value + 1
		var m_tween: Tween = get_tree().create_tween()
		m_tween.tween_property(melting_progress, "value", new_melt_val, 1.29).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	else:
		# decrease
		var new_melt_val = melting_progress.value - 1
		new_melt_val = clamp(new_melt_val, 0, melting_progress.max_value)
		var m_tween_2: Tween = get_tree().create_tween()
		m_tween_2.tween_property(melting_progress, "value", new_melt_val, 1.29).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)


	if is_equal_approx(melting_progress.value, melting_target) or melting_progress.value > melting_target:
		if melting_goal_reached == false:
			re_enable_water()
			melting_goal_reached = true
			print_debug("Melting done")
			# signal rather ?, make sure it is changed only.
			# could use use change prop and it would check if the false->true happened
			# for now ignoring
		# do this once, then stop tracking ?
		# show water ?
		# then what ?
		# kill off the emitter ?

var smog_emit_timer: Timer
func start_smog_loop():
	smog_emit_timer.start()
	var progress_bar_tween: Tween = get_tree().create_tween()
	progress_bar_tween.tween_property(smog_progress_bar, "value", 100, 60).from(0).set_trans(Tween.TRANS_LINEAR)

var smog_emitter_have_power: bool = true
# called from smog_emit_timer.timeout
func reset_smog():
	if not smog_emitter_have_power:
		return

	vfx_emit_smog()
	# Reset progress bar
	# Do release of progress. Release of smog.
	# Also can do wait after it it 100, wait another minute before releaseing smog
	# so fill to 100 in 60s, then wait 60s relase in 5s, towards player, flood like water. Reset
	# For now ignore

	var progress_bar_tween: Tween = get_tree().create_tween()
	progress_bar_tween.tween_property(smog_progress_bar, "value", 100, 60).from(0).set_trans(Tween.TRANS_LINEAR)
	# smog to 1 from level editor
	tile_object_component.set_smog_from_level_editor()
	# TODO: reset smog_amount to 30, once we have smog_amount in TileObject
	# or keep adding more smog for each repeat ?

func load_level():
	level_controller.load_default_hints()
	level_controller.load_user_preferences()
	level_controller.save_user_preferences()

	# TODO: add new tree stumps ruins
	var base_single_pos:Vector2i = Vector2i(-9, -14)
	level_controller.level_data._base_coords = [base_single_pos]
	var mycelium_positions = level_controller.get_coords_in_circle(base_single_pos, 1)
	for coords in mycelium_positions:
		level_controller.add_object(MyceliumObject.new(coords))
		level_controller.get_tile_at(coords).set_discovered_in_radius(true, 5)

	#level_controller.level_data._base_coords = [Vector2i(0,0)]
	var seed_mycelium = level_controller.get_tile_at(base_single_pos).get_mycelium()
	seed_mycelium.set_state(MyceliumObject.MyceliumState.Idle)
	seed_mycelium.set_health(100)

	add_tree_stumps_ruin()

	var coords: Vector2i = Vector2i.ZERO
	var resources: Array[ResourceObject] = []

	# Tank Ruin
	coords = Vector2i(-10, -10)
	resources = [
		ResourceObject.new(coords, ResourceObject.ResourceType.Minerals, 2000)
	]
	for resource in resources:
		level_controller.add_resource(resource)
	level_controller.add_object(
		RuinObject.new(
			coords,
			Vector2i(1, 2),
			'ruin_tank_02',
			resources,
		)
	)


	coords = Vector2i(1, 11)
	resources = [ResourceObject.new(coords, ResourceObject.ResourceType.Carbon, 100)]
	for resource in resources:
		level_controller.add_resource(resource)
	level_controller.add_object(RuinObject.new(coords, Vector2i(1, 1), 'ruin_log_02', resources))

	coords = Vector2i(-1, 15)
	resources = [ResourceObject.new(coords, ResourceObject.ResourceType.Carbon, 100)]
	for resource in resources:
		level_controller.add_resource(resource)
	level_controller.add_object(RuinObject.new(coords, Vector2i(1, 1), 'ruin_log_01', resources))

	coords = Vector2i(-4,-4)
	var resources2:  Array[ResourceObject] = [ResourceObject.new(coords, ResourceObject.ResourceType.Carbon, 100)]
	for resource in resources2:
		level_controller.add_resource(resource)
	level_controller.add_object(RuinObject.new(coords, Vector2i(1, 1), 'ruin_log_02', resources2))

	coords = Vector2i(1, -6)
	var resources3:  Array[ResourceObject] = [ResourceObject.new(coords, ResourceObject.ResourceType.Carbon, 100)]
	for resource in resources3:
		level_controller.add_resource(resource)
	level_controller.add_object(RuinObject.new(coords, Vector2i(1, 1), 'ruin_log_01', resources3))


func add_tree_stumps_ruin():
	## TODO
	# TODO: have a tilemap -> ruins
	# as a way to have a level editor
	# search for ID in tilemap -> replace with instance.
	# look at LDTK for saving custom data as well
	# Like amount of resources for this ruin instance
	# ruin_tree_stump_01
	var coords_list: = [Vector2i(3, 3), Vector2i(-2, 3), Vector2i(-1, 3), Vector2i(-4, 3),]
	for coords in coords_list:
		var resources:  Array[ResourceObject] = [ResourceObject.new(coords, ResourceObject.ResourceType.Carbon, 100)]
		for resource in resources:
			level_controller.add_resource(resource)
		level_controller.add_object(RuinObject.new(coords, Vector2i(1, 1), 'ruin_tree_stump_01', resources))

# ruin_tree_stump_01_256
func add_tree_stumps_ruin_256():
	## TODO
	# TODO: have a tilemap -> ruins
	# as a way to have a level editor
	# search for ID in tilemap -> replace with instance.
	# look at LDTK for saving custom data as well
	# Like amount of resources for this ruin instance
	# ruin_tree_stump_01
	var coords_list: = [Vector2i(3, 5), Vector2i(-3, 5), Vector2i(-2, 5), Vector2i(-5, 5),]
	for coords in coords_list:
		var resources:  Array[ResourceObject] = [ResourceObject.new(coords, ResourceObject.ResourceType.Carbon, 100)]
		for resource in resources:
			level_controller.add_resource(resource)
		level_controller.add_object(RuinObject.new(coords, Vector2i(1, 1), 'ruin_tree_stump_01_256', resources))

# add position for worms here
# also need to keep track of removed org matter
# then can schedule worms to go and eat, before reemerging, check if ruin still there,
# or on deleting ruin, remove the order for worm
# maybe worms are just waiting, so we can ingore the delay and make them instant in appearing.
# with some rand.
# if the ruin just sits there, worms should reappear
# lookup from dictionary, and eat one
# also do the population control in simple way.
# maybe just keep population number.
# increase after one has eaten.
# need to sim hunger, and kill of if has not been able to eat.
# meaning decrease population and surface dead worm.
#
# another aspect was, the dead of worm after replication,
# eat-> replicate -> kick off timer to kill (decrease population, show dead body on the surface)

@export var worm_population:float = 1. # or float to increase population +0.5 on every fead worm
@export var worm_on_screen: int = 0

func _on_model_changed(change: Dictionary):
	super._on_model_changed(change)

	if change.type == ModelObject.Type.Ruin:
		if change.prev == null:
			if change.curr.get_ruin_type() == 'ruin_organic_matter':
				pass
				if worm_on_screen < worm_population:
# Need to check population
# How to break it into separate thing that we can manage
					var coords: Vector2i = change.coords
					var res = level_controller.add_movable(CreatureObject.new(coords, CreatureObject.CreatureType.Worm))
					worm_on_screen += 1
	# capture worm deletion
	if change.type == ModelObject.Type.Creature:
		if change.curr == null:
			var creature: CreatureObject = change.prev
			if creature.get_subtype() == CreatureObject.CreatureType.Worm:
				print_debug("Deleted: ", change.prev)
				worm_on_screen -= 1
				worm_population += 0.2
