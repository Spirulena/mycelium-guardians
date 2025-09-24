class_name MyceliumGrowingMapPresenter extends Node2D

var _model: MyceliumGrowingObject
var _parent: LevelView
var _controller: MyceliumGrowingController
var _scene: MyceliumGrowingScene
var _neighbours_nodes: Dictionary

func _init(model, parent):
	_model = model
	_parent = parent
	_controller = MyceliumGrowingController.new(model)
	_model.state_changed.connect(_on_state_changed)
	randomize()
	_model._mycelium_gfx_index = randi_range(0, 6)
	name = "MyceliumGrowingMapPresenter_%d_%d" % [_model.get_coords().x, _model.get_coords().y]
	_neighbours_nodes = {}

func _ready():
	add_child(_controller)
	var coords = _model.get_coords()
	self.name = "mycelium_growing_tile_%d_%d" % [coords.x, coords.y]
	self.position = _parent.to_position(coords)
	# calculate neighbours, and pass matrix ?
	var neighbours = _controller.get_neighbours()
	_scene = Loader.get_loader().return_scene("mycelium_growing").instantiate()
	_scene.set_frames(_model._mycelium_gfx_index)
	add_child(_scene)
	_neighbours_nodes = {
		Vector2i.UP: _scene.get_node("modulate/top_bottom"),
		Vector2i.DOWN: _scene.get_node("modulate/bottom_top"),
		Vector2i.LEFT: _scene.get_node("modulate/left_right"),
		Vector2i.RIGHT: _scene.get_node("modulate/right_left"),
	}
	for direction in neighbours.keys():
		_neighbours_nodes[direction].visible = neighbours[direction]

func _on_state_changed(change):
	if change.prop == 'state' and change.curr == ModelObject.State.Removed:
		#print("removing %s" % name)
		await get_tree().process_frame
		queue_free()
