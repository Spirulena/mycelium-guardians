class_name MyceliumQueueMapPresenter extends Node2D

var _model: MyceliumQueueObject
var _view: LevelView
var _controller: MyceliumQueueController
var _scene


func _init(model: MyceliumQueueObject, parent: LevelView):
	_model = model
	_view = parent
	_controller = MyceliumQueueController.new(model)
	_model.state_changed.connect(_on_state_changed)
	name = "MyceliumQueueMapPresenter_%d_%d" % [_model.get_coords().x, _model.get_coords().y]

func _ready():
	add_child(_controller)
	var coords = _model.get_coords()
	position = _view.to_position(coords)
	_scene = Loader.get_loader().return_scene("mycelium_queue").instantiate()
	add_child(_scene)

func _on_state_changed(change):
	if change.prop == 'state' and change.curr == ModelObject.State.Removed:
		#print("removing %s" % name)
		queue_free()
