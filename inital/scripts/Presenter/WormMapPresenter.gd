class_name WormMapPresenter extends Node2D

var _parent
var _model: CreatureObject
var _scene

func _init(model, parent):
	_model = model
	_parent = parent
	_scene = null
	y_sort_enabled = true
	name = "WormPresenter_%d_%d" % [_model.get_coords().x, _model.get_coords().y]

func _ready():
	self.position = _parent.to_position(_model.get_coords())
	_scene = Loader.get_loader().return_scene("worm").instantiate()
	add_child(_scene)

	_scene.animation_player.play("eat")
	_scene.animation_player.animation_finished.connect(func(anim_name): _cleanup())

func _cleanup():
	LevelController.get_level_controller().remove_movable(_model)
	_scene.queue_free()
	queue_free()
