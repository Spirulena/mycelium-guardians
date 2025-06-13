class_name BuildingMapPresenter extends Node2D

@export var genetics_panel_hover: Panel = preload("res://Scenes/Genes/building_map_presenter_genetics_panel.tscn").instantiate()

@onready var genetics_label: Label

@onready var decay_timer: Timer
@onready var decay_progress_bar: ProgressBar
# TODO: Move to LevelPresenter
@onready var growth_emitter_instance: GPUParticles2D
#@onready var growth_finished_efx: GPUParticles2D
@onready var mutation_button: Node2D

var _decay_time: int = 12
# move to model ?
var _parent: LevelView
var _controller
var _model: BuildingObject
var _scene
var _lc: LevelController
var _effect_radius: TileMap
var _selected_structure_map_ui: Node2D
var _selected_animation: AnimationPlayer

var scale_size_by_radius: Dictionary = {
	1: Vector2(0.4, 0.4),
	2: Vector2(0.6, 0.6),
	3: Vector2(0.8, 0.8),
	4: Vector2(1.0, 1.0),
	5: Vector2(1.2, 1.2),
}

func _init(model, parent):
	_model = model
	_parent = parent
	_controller = BuildingController.new(model)
	#_model.health_changed.connect(_health_changed)
	_model.state_changed.connect(_building_state_changed)
	_model.building_changed.connect(_on_building_changed)
	_lc = LevelController.get_level_controller()
	name = "BuildingMapPresenter_%d_%d" % [_model.get_coords().x, _model.get_coords().y]

var structure_sfx: Dictionary = {
	BuildingObject.StructureType.Storage_Water : SfxPlayer.SFX.structure_select_storage_water,
	BuildingObject.StructureType.Storage_Energy : SfxPlayer.SFX.structure_select_storage_energy,
	BuildingObject.StructureType.Storage_Minerals : SfxPlayer.SFX.structure_select_storage_minerals,
	BuildingObject.StructureType.Storage_Carbon : SfxPlayer.SFX.structure_select_storage_carbon,
	BuildingObject.StructureType.Absorber_Radiation : SfxPlayer.SFX.structure_select_absorber_radiation,
	BuildingObject.StructureType.Absorber_Smog : SfxPlayer.SFX.structure_select_absorber_smog,
	BuildingObject.StructureType.Emitter_Spore : SfxPlayer.SFX.structure_select_absorber_smog,
	BuildingObject.StructureType.Export_Center : SfxPlayer.SFX.structure_select_export_center,
}
# TODO: add visual element showing it is selected.
# _model.is_selected: bool ? and signal when changed. direct.
func _on_building_changed(change):
	if change.type == 'production_active':
		if change.curr == false:
			if _scene.has_method('pause_cycle'):
				_scene.pause_cycle()
		elif change.curr == true:
			if _scene.has_method('un_pause_cycle'):
				_scene.un_pause_cycle()
	if change.type == 'ui_selected':
		selected_animate(change.curr) # show or hide animation
		if change.curr == true:
			show_effect_radius()
			_parent.sfx.play_sfx_type(structure_sfx.get(_model.get_building_type()))
		elif change.curr == false:
			hide_effect_radius()
		# move to local here, so we can keep it DRY
		#if _scene.has_method('set_selected'):
			#_scene.set_selected(change)
			# show the effect radius here, when it is build

	elif change.type == 'set_value' and change.prop == 'production_efficiency' and change.curr != null:
		if _scene.has_method('adjust_speed'):
			_scene.adjust_speed(change.curr)
	elif change.type == 'set_value' and change.prop == 'radius': # update radius
		# scale the size as well of scene
		var new_scale: Vector2 = scale_size_by_radius[_model.get_radius()]
		var tween_s: Tween = _scene.create_tween()
		tween_s.tween_property(_scene, "scale", new_scale, 0.3).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN_OUT)
		set_effect_radius(_lc.get_coords_in_circle(Vector2i.ZERO, _model.get_radius()))
	#elif change.type == 'set_value' and change.prop == 'radius': # update radius
		#set_effect_radius(_lc.get_coords_in_circle(Vector2i.ZERO, _model.get_radius()))

			#'type': 'set_value',
			#'prop': key,
		#}
	#'curr': active,
	#'prev': prev,
	#'coords': get_coords(),
	#'type': 'production_active',

func selected_animate(state: bool):
	_selected_structure_map_ui.visible = state

func _building_state_changed(change):
	if change.prop == 'state' and change.curr == BuildingObject.BuildingState.Building:
		# animate reveal
		set_process(true)
		if _scene.has_method("set_color"):
			_scene.set_color(_model.base_color)

	if change.prop == 'state' and change.curr == ModelObject.State.Removed:
		queue_free()
	if change.prop == 'state' and change.curr != change.prev and change.curr == BuildingObject.BuildingState.Done:

		if _model.mutation:
			if _model.get_building_type() != BuildingObject.StructureType.Absorber_Smog:
				print_debug("GENE: not smog absorber")
			set_genetics_label() # update label text, if it became mutated now
			print_debug("GENE: Got mutation on grown one")
			# show icon.
			if _scene.has_method("set_color"):
				_scene.set_color(_model.base_color)
				# save colour ?
			mutation_button = Loader.get_loader().return_scene('mutation_icon').instantiate()
			add_child(mutation_button) # 'mutation_icon'
			mutation_button._model = _model
			# connect to mutation pressed
			# or just pass model,

		#growth_emitter_instance.queue_free()
		set_process(false)
		# build
		if _scene.has_method('start_cycle'):
			if _scene.has_method('set_model'):
				_scene.set_model(_model)
			_scene.start_cycle()

		# DECAY
		decay_timer = Timer.new()
		decay_timer.wait_time = _model.base_decay_time
		decay_timer.autostart = true
		decay_timer.name = "decay_timer"
		decay_timer.timeout.connect(decay_timeout)
		add_child(decay_timer)

		# Decay progress bar
		# SHOW in ALT Mode
		var decay_ctrl: Control = Control.new()
		decay_ctrl.visible = true
		decay_ctrl.mouse_filter = Control.MOUSE_FILTER_PASS
		decay_ctrl.size = Vector2(50, 20)
		decay_ctrl.position = Vector2(-(50/2), 0+20)
		decay_ctrl.z_index = 60
		decay_ctrl.z_as_relative = false
		decay_ctrl.y_sort_enabled = true

		add_child(decay_ctrl)
		var decay_hbox: HBoxContainer = HBoxContainer.new()
		decay_hbox.set_anchors_preset(Control.PRESET_FULL_RECT)
		decay_ctrl.add_child(decay_hbox)
		var decay_label: Label = Label.new()
		decay_label.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		decay_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		decay_label.text = "λ"
		#decay_label.z_index = 200
		decay_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		decay_label.add_theme_constant_override("font_size", 10)
		decay_hbox.add_child(decay_label)
		# could just do with progress bar without lambda label,
		# better to have it in scene in this setup to set all the size flags
		decay_progress_bar = ProgressBar.new()
		decay_progress_bar.size = Vector2(50, 20)
		decay_progress_bar.value = 100
		decay_progress_bar.max_value = 100
		#decay_progress_bar.z_index = 200
		decay_progress_bar.add_theme_constant_override("font_size", 30)
		decay_progress_bar.tooltip_text = "Decay"
		decay_progress_bar.set_anchors_preset(Control.PRESET_FULL_RECT)
		#decay_progress_bar.add_theme_font_size_override("font_size", 30)
		decay_progress_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		decay_progress_bar.show_percentage = true
		decay_hbox.add_child(decay_progress_bar)
		var tween_pb: Tween = get_tree().create_tween()
		tween_pb.tween_property(decay_progress_bar, "value", 0, _model.base_decay_time).from(100).set_trans(Tween.TRANS_LINEAR)


func decay_timeout():
	print_debug("Decay timeout: ", _model.get_coords())
	# self delete
	# efx
	_lc.remove_object(_model)
	# TODO: add _lc.decay_mushroom(_model)
	# For now add resources and ruins
	add_ruin()

# TODO make organic matter ruin
func add_ruin():
	# TODO: move to CTRL ?
	var cost = BuildingObject.get_growth_cost_static(_model._building_type, _model.radius)
	var resources:  Array[ResourceObject]
	for resource in cost.keys():
		if not is_zero_approx(cost[resource]):
			var res = ResourceObject.new(_model.get_coords(), resource, cost[resource])
			resources.append(res)
			_lc.add_resource(res)
	_lc.add_object(RuinObject.new(_model.get_coords(), Vector2i(1, 1), 'ruin_organic_matter', resources))

#func _health_changed(change):
	#if change.prop == 'health' and _model.get_state() == BuildingObject.BuildingState.Building:
		#if _scene.has_method('reveal'):
			#_scene.reveal(change.curr)
		#else:
			#_scene.scale = change.curr / 100.0 * Vector2(1,1)

func _process(delta):
	if _scene.has_method('reveal'):
		_scene.reveal(_model.get_health())
	else:
		_scene.scale = _model.get_health() / 100.0 * scale_size_by_radius[_model.get_radius()]
		# have a speed factor, based on radius

func set_genetics_label():
	# add mutation stat
	# Add genetics number
	var mutation: String = ""
	if _model.mutation and _model.get_state() == BuildingObject.BuildingState.Done:
		mutation = " Mutation %s" % _model.mutation_id
	var text: String = "Generation #%d%s" % [_model.base_generation, mutation]
	text = text + "\n" + "Decay                | (%0.2fs)" % [_model.base_decay_time]
	var smog_line: =   "Smog change  | (%0.3f/s)" % [_model.base_smog_change]
	var growth_line: = "Growth speed | (%d%%)" % [int(_model.base_growth_speed_factor*100)]
	text = "%s\n%s\n%s" % [text, smog_line, growth_line]
	# Then use RTFLabel
	if is_instance_valid(genetics_label):
		genetics_label.text = "%s" % text

func _on_mouse_entered_scene():
	print_debug("BuildingMapPresenter: Mouse entered")
	set_genetics_label()
	genetics_panel_hover.show()

func _on_mouse_exited_scene():
	print_debug("BuildingMapPresenter: Mouse exited")
	genetics_panel_hover.hide()

var hover_area: Area2D
func _ready():
	genetics_panel_hover.visible = false
	genetics_panel_hover.name = "genetics_panel_hover"
	add_child(genetics_panel_hover)
	genetics_label = genetics_panel_hover.get_node("MarginContainer2/Label")

	_parent.play_sound(SfxPlayer.SFX.place_structure)

	var coords = _model.get_coords()
	self.position = _parent.to_position(coords)

	var building_enum = _model.get_building_type()
	_scene = Loader.get_loader().return_scene(building_enum).instantiate()
	if building_enum == BuildingObject.StructureType.Absorber_Smog:
		hover_area = _scene.get_node("Area2D")
		if is_instance_valid(hover_area):
			hover_area.mouse_entered.connect(_on_mouse_entered_scene)
			hover_area.mouse_exited.connect(_on_mouse_exited_scene)

	_effect_radius = Loader.get_loader().return_scene('effect_radius').instantiate()
	_effect_radius.name = "effect_radius"
	_selected_structure_map_ui = Loader.get_loader().return_scene('selected_structure_map_ui').instantiate()

	add_child(_scene)
	add_child(_effect_radius)
	hide_effect_radius()
	add_child(_selected_structure_map_ui)
	selected_animate(false)
	#_selected_animation = _selected_structure_map_ui.get_node("AnimationPlayer")
	#_selected_animation.play("selected")

	if _scene.has_method("set_model"):
		_scene.set_model(_model)

	if _scene.has_method("set_color"):
		_scene.set_color(_model.base_color)
	if _model.get_radius() > 0:
		set_effect_radius(_lc.get_coords_in_circle(Vector2i.ZERO, _model.get_radius()))

	if _model.get_building_type() == BuildingObject.StructureType.Absorber_Smog:
		pass

	## TODO: move to LevelPresenter
	growth_emitter_instance = Loader.get_loader().return_scene("growth_emitter").instantiate()
	#growth_emitter_instance.emitting = true
	add_child(growth_emitter_instance)
	growth_emitter_instance.restart()
	growth_emitter_instance.finished.connect(func(): growth_emitter_instance.queue_free())

	#growth_finished_efx = Loader.get_loader().return_scene("growth_finished_efx_scene").instantiate()
	#growth_finished_efx.emitting = false
	#add_child(growth_finished_efx)

	#growth_emitter_instance.emitting = true
	#growth_emitter_instance.restart()

	add_child(_controller)
	#add_child(DegradationController.new(_model))
	add_child(HealthController.new(_model))


func show_effect_radius():
	var tween_a: Tween = _effect_radius.create_tween()
	tween_a.tween_property(_effect_radius, "modulate:a", 1.0, 0.2).from(0.0).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)
	tween_a.tween_property(_effect_radius, "modulate:a", 0.6, 0.1).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)
	_effect_radius.show()

func hide_effect_radius():
	var tween_a: Tween = _effect_radius.create_tween()
	tween_a.tween_property(_effect_radius, "modulate:a", 0.0, 0.2).from(0.6).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)
	#tween_a.tween_property(_effect_radius, "modulate:a", 0.8, 0.1).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)
	tween_a.tween_callback(_effect_radius.hide)
	#_effect_radius.hide()

func set_effect_radius(coords_list: Array[Vector2i]):
	_effect_radius.clear()
	for coords in coords_list:
		_effect_radius.set_cell(0, coords, 3, Vector2i(0, 2))

func pruned():
	var tween: Tween = self.create_tween()
	tween.tween_property(self, "modulate", Color(0.5, 0.5, 0.5, 1.0), 2.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(self, "scale", Vector2(0,0), 2.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)

func degraded():
	var tween: Tween = self.create_tween()
	tween.tween_property(self, "modulate", Color(0.5, 0.5, 0.5, 1.0), 2.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(self, "scale", Vector2(0,0), 2.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	await tween.finished
