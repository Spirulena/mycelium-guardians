class_name FFCrasherMapPresenter extends Node2D

var _parent: LevelView
var _controller: FFCrasherController
var _model: CreatureObject #TODO: or make new FFCrasherObject
var _scene
var _lc: LevelController

func _init(model, parent):
	_lc = LevelController.get_level_controller()
	_model = model
	_parent = parent
	_scene = null
	_controller = FFCrasherController.new(model, self)
	_model.movable_changed.connect(_movable_changed)
	y_sort_enabled = true

func _movable_changed(change):
	if change.type == 'tile':
		var discovered = _lc.get_tile_at(change.curr).get_discovered()
		if discovered:
			var alpha_tween = self.create_tween() as Tween
			alpha_tween.tween_property(self, "modulate:a", 1.0, 1.0)

	#if change.type == 'movement':
		#var coords = _model.get_coords()
		#var movement = _model.get_movement()
#
		#var curr_position = _parent.to_position(coords)
		#var next_position = _parent.to_position(coords + movement.v)
#
		#self.position = curr_position.lerp(next_position, movement.t)

# Movement change.type movement, to process
func _process(delta):
	var coords = _model.get_coords()
	if coords == null:
		return
	var movement = _model.get_movement()

	var curr_position = _parent.to_position(coords)
	var next_position = _parent.to_position(coords + movement.v)

	self.position = curr_position.lerp(next_position, movement.t)

func _ready():
	var discovered_location = _lc.get_tile_at(_model.get_coords()).get_discovered()
	if not discovered_location:
		modulate.a = 0

	self.position = _parent.to_position(_model.get_coords())
	_scene = Loader.get_loader().return_scene("ff_crasher_01").instantiate()
	add_child(_scene)
	add_child(_controller)

func launch_flare():
	print_debug("Launching flare - TODO: add anim")
	await _scene.get_node("AnimatedSprite2D").animation_looped
	_scene.get_node("AnimatedSprite2D").stop()
	_scene.get_node("AnimatedSprite2D").play("flare_stop")
	await _scene.get_node("AnimatedSprite2D").animation_finished
	_scene.get_node("AnimatedSprite2D").play("flare_post_stop")
	# play flare anim.
	pass

func self_destruct():
	# play anim,
	# white out the screen, on canvas layer. or just a big circle above the location.
	# Mute sound for a sec.
	# Fade out and in.
	mute_for_explosion()
	print_debug("FFMapPresenter. Self destruct")
	_scene.get_node("AnimationPlayer").play("explode")
	# Silence the master fader.

func mute_for_explosion():
	var bus_index:int = AudioServer.get_bus_index("pre_master")
	var current_bus_volume = db_to_linear(
		AudioServer.get_bus_volume_db(bus_index)
	)
	change_audio_bus_volume(0.0, bus_index)
	var tween: Tween = self.create_tween()
	tween.tween_method(change_audio_bus_volume.bind(bus_index), current_bus_volume, 0.0, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween.tween_method(change_audio_bus_volume.bind(bus_index), 0.0, current_bus_volume, 0.5).set_delay(1.3).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)

func change_audio_bus_volume(value: float, bus_index: int):
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
