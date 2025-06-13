class_name SmogTilePresenter extends Node2D

var _model: TileObject
var _parent: LevelView
var _scene
var _scene_label: Label
var _random_speed
var _new_val: Vector2
var _base_alpha: float
var _curr_alpha: float

func _init(model, parent):
	randomize()
	_model = model
	_parent = parent
	_random_speed = randf_range(1, 3.8)
	_new_val = Vector2.ZERO
	_base_alpha = 0.5
	_curr_alpha = 0.0

func sigmoid(val):
	return 1.0 / (1.0 + exp(-val))

func get_alpha_of_smog(smog):
	var shift = (smog * 10.0) - 5.0
	var sigmoid_val = sigmoid(shift)
	return sigmoid_val * _base_alpha

func _ready():
	_model.tile_changed.connect(_tile_changed)
	_model.set_smog_presenter(self)
	var coords = _model.get_coords()
	self.position = _parent.to_position(coords)
	name = "SmogTile_%d_%d" % [coords.x, coords.y]

	_scene = Loader.get_loader().return_scene('SmogTileShader512').instantiate()
	_scene.material.set("shader_parameter/speed_multiplier", _random_speed)
	_scene.visible = true
	_scene_label = _scene.get_node("Label")
	_scene_label.add_to_group("smog_labels")

	add_child(_scene)
	# by default invisible ?
	# trigger by event or have it set in tile map
	# check if the map is there

	make_visible()

	#if _model.get_discovered():
		#make_visible()
	#else:
		#_scene.visible = false # Do we need that ?
		#set_alpha(0.0)

	# TMP: remove visibility notifier for now
	#var screen_enabler: = VisibleOnScreenEnabler2D.new()
	#screen_enabler.rect = Rect2(-128, -128, 128, 128)
	#add_child(screen_enabler)

func set_alpha(val):
	_scene.material.set("shader_parameter/baseline_alpha", val)

# 1 and higher -> baseline_alpha
# <= 0  - zero
# make visible, _baseline_alpha, based on smog amount
func make_visible(): # This now updates it based on smog
	var smog = _model.get_smog()
	#_scene.visible = _model.get_discovered()
	var alpha_of_smog = get_alpha_of_smog(smog)
	var alpha_tween = _scene.create_tween() as Tween
	alpha_tween.tween_method(set_alpha, _curr_alpha, alpha_of_smog, 1.0)
	_curr_alpha = get_alpha_of_smog(smog)

func _tile_changed(change):
	if change.type == 'discovered' and change.curr == true and change.prev == false:
		make_visible()
	# Smog changed.
	if change.type == 'smog' and change.prev != change.curr:
		make_visible()
		_scene_label.text = "%0.2f" % change.curr
		# TODO: add sucking, manga action lines, 4 frames ? that it's sucking,
		# TODO: add task for itw
	# smog amount changed

	# smog changed
			#'type': 'smog',
			#'coords': _coords,
			#'tile': self,
			#'prev': prev_smog,
			#'curr': smog,

#func _process(delta):
	#_new_val = LevelController.get_level_controller().get_wind_direction() * 0.1
	#_scene.material.set("shader_parameter/v_speed",
		#_new_val
	#)

# Old smog tile was doing
# lc.get_wind_direction() * delta * lc.get_wind_speed() * speed
# var speed = 0.9
# speed += randf_range(-3, 3)
