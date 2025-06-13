class_name PlantMapPresenter extends Node2D

var _model: PlantObject
var _parent: LevelView
var _controller: PlantController
var _scene
var _timer: Timer
var _lc: LevelController

func _init(model, parent):
	_lc = LevelController.get_level_controller()
	_model = model
	_parent = parent
	_model.state_changed.connect(_state_changed)
	_scene = null
	name = "PlantMapPresenter_%d_%d" % [_model.get_coords().x, _model.get_coords().y]
	y_sort_enabled = true

func _ready():
	_timer = Timer.new()
	_timer.wait_time = 2
	_timer.autostart = true
	_timer.name = "Tick"
	_timer.timeout.connect(_on_timer_timeout)
	add_child(_timer)

	_scene = Loader.get_loader().return_scene(_model.get_scene_key()).instantiate()
	_scene.position = _parent.to_position(_model.get_coords())
	add_child(_scene)

	# TODO: add controller. ?
	# Pass presenter to controller ?
	add_child(PlantController.new(_model))

	#add_child(HealthController.new(_model))
	# Where to check if plant is growing in smog.
	if _model.get_subtype() == PlantObject.PlantType.RoundCane_01:
		if _model.get_state() == PlantObject.PlantState.Growing:
			var smog = LevelController.get_level_controller().get_smog(_model.get_coords())
			if smog > 0:
				# This needs to be captured in model
				_scene.get_node("AnimationPlayer").play("Smog_Grow")
				_scene.get_node("AnimationPlayer").animation_finished.connect(func(anim_name):
					if anim_name == "Smog_Grow":
						_model.set_state(PlantObject.PlantState.Crashed)
					)
			elif  smog <= 1:
				_scene.get_node("AnimationPlayer").play("GrowPOC")
				_scene.get_node("AnimationPlayer").animation_finished.connect(func(anim_name):
					if anim_name == "GrowPOC":
						# TODO: this should emit more resources
						_model.set_state(PlantObject.PlantState.Crashed)
					)
	elif _model.get_subtype() == PlantObject.PlantType.DryGrass:
		pass

# Instead of removal, make it smashed
func _state_changed(change):
	if change.curr != change.prev and change.curr == ModelObject.State.Removed:
		# TODO: animation, decompose first, then give some resources
		queue_free()
	if _model.get_subtype() == PlantObject.PlantType.RoundCane_01:
		if change.curr == ModelObject.State.Removed:
			if is_instance_valid(_scene):
				#print_debug("ModelObject.State.Removed: ", change)
				_scene.queue_free()
			queue_free()
		if change.curr == PlantObject.PlantState.Crashed:
			_scene.get_node("AnimationPlayer").play("Flat")

func _on_timer_timeout():
	if _model.get_subtype() == PlantObject.PlantType.DryGrass:
		if _scene.has_method("set_grass_shader"):
			var smog_level = _lc.get_tile_at(_model.get_coords()).get_smog()
			_scene.set_grass_shader(smog_level)
