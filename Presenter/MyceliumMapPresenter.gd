class_name MyceliumMapPresenter extends Node2D

var _model: MyceliumObject
var _parent
var _scene: MyceliumScene
var _controller: MyceliumController
var _lc: LevelController
var _neighbours_nodes: Dictionary
var _tile: TileObject

func _init(model, parent):
	_model = model
	_parent = parent
	_model.health_changed.connect(_mycelium_changed)
	_model.state_changed.connect(_state_changed)
	_controller = MyceliumController.new(model)
	_lc = LevelController.get_level_controller()
	_tile = _lc.get_tile_at(_model.get_coords())
	var t = _tile.get_mycelium()
	var t2 = _lc.level_data._all_mycelium.get(_model.get_coords())
	pass


func _state_changed(change):
	# TODO: Change to switch
	if change.curr == MyceliumObject.MyceliumState.ReleasingAcid:
		# FIXME: this can be null
		_scene.release_acid(_model.get_coords())
	elif change.curr == ModelObject.State.Crashed:
		pass
		# Could also retract the circle, if there is one there
		var tween: Tween = _scene.create_tween()
		tween.tween_property(_scene, "modulate", Color.BLACK, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
		tween.tween_property(_scene, "modulate:a", 0.4, randf_range(1.4, 2.0)).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
		tween.tween_property(_scene, "modulate", Color(0.411765, 0.411765, 0.411765, 0.4), randf_range(4,6)).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_delay(randf_range(4,6))
		tween.tween_property(_scene, "modulate", Color.WHITE, 3.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_delay(randf_range(3,4))
	# Thickened
	elif  change.curr == MyceliumObject.MyceliumState.Thickened:
		if _scene.has_method("thicken"):
			_scene.thicken()
		else:
			print_debug("Missing VFX thicken on mycelium")

	elif change.curr == ModelObject.State.Removed:
		_scene.pruned()
		queue_free()

func _mycelium_changed(change):
	pass

func _ready():

	add_child(_controller)
	var coords = _model.get_coords()
	self.name = "mycelium_tile_%d_%d" % [coords.x, coords.y]
	self.position = _parent.to_position(coords)

	var neighbours = _controller.get_neighbours()


	_scene = Loader.get_loader().return_scene("Mycelium").instantiate()
	_scene.set_model(_model)
	add_child(_scene)
	_neighbours_nodes = {
		Vector2i.UP: _scene.get_node("modulate/top_bottom"),
		Vector2i.DOWN: _scene.get_node("modulate/bottom_top"),
		Vector2i.LEFT: _scene.get_node("modulate/left_right"),
		Vector2i.RIGHT: _scene.get_node("modulate/right_left"),
	}
	for direction in neighbours.keys():
		var frame_count = _neighbours_nodes[direction].sprite_frames.get_frame_count("default")
		var last_frame = frame_count - 1
		_neighbours_nodes[direction].visible = neighbours[direction]
		_neighbours_nodes[direction].frame = last_frame
	#_scene.idle()
	#_scene.get_node("AnimationPlayer").play("Purify")
	add_child(HealthController.new(_model))
