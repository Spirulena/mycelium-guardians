class_name ResourceBallMapPresenter extends Node2D

var _model: ResourceBallObject
var _parent: LevelView
var _instance
var _controller: ResourceBallController
var _region_rect_resource: Dictionary

func _init(model, parent):
	_model = model
	_parent = parent
	_model.state_changed.connect(_state_changed)
	_region_rect_resource = {
		ResourceObject.ResourceType.Water: Rect2(0,0, 54, 40),
		ResourceObject.ResourceType.Minerals: Rect2(54, 0, 54, 40),
		ResourceObject.ResourceType.Carbon: Rect2(0, 40, 54, 40),
		ResourceObject.ResourceType.Energy: Rect2(54, 40, 54, 40),
	}
	_model.movable_changed.connect(_movable_changed)

func _movable_changed(change):
	if change.type == 'direction':
		curr_position = _parent.to_position(_model._coords)
		next_position = _parent.to_position(_model._coords + _model._movement.v)

func _movable_changed2(change):
	if change.type == 'movement':
		var coords = _model.get_coords()
		var movement = _model.get_movement()

		var curr_position: Vector2 = _parent.to_position(coords)
		var next_position: Vector2 = _parent.to_position(coords + movement.v)

		self.position = curr_position.lerp(next_position, movement.t)

var tile_size: Vector2 = Vector2(256, 128)
func to_position(coords: Vector2i) -> Vector2:
	return tile_size * Vector2(coords)
var curr_position: Vector2 = Vector2.ZERO
var next_position: Vector2 = Vector2.ZERO

const TILE_WIDTH := 256  # Adjust as per your tile's width
const TILE_HEIGHT := 128  # Adjust as per your tile's height

func to_pixel_position(grid_position: Vector2i) -> Vector2:
	return Vector2(
		(grid_position.x - grid_position.y) * TILE_WIDTH / 2.0 + 128,
		(grid_position.x + grid_position.y) * TILE_HEIGHT / 2.0 + 64
	)

func _process(delta):
	#var coords = _model.get_coords()
	##if coords == null:
		##return
	#var movement = _model.get_movement()
	#if movement.v == null:
		#return
	#var curr_position = _parent.to_position(coords)
	#var next_position = _parent.to_position(coords + movement.v)
	#curr_position = to_pixel_position(_model._coords)
	#next_position = to_pixel_position(_model._coords + _model._movement.v)
	#var new_pos = curr_position.lerp(next_position, movement.t)
	position = curr_position.lerp(next_position, _model._movement.t)

func _ready():
	var coords = _model.get_coords()
	_instance = Loader.get_loader().return_scene("resource_ball_scene2").instantiate()
	# get tile, get resource at
	var tile = LevelController.get_level_controller().get_tile_at(_model.get_coords())
	var resource = tile.get_resource()
	if resource == null:
		#print_debug("Resource deleted, ball still spawned")
		return 
	var resource_type = resource.get_resource_type()

	_instance.region_rect = _region_rect_resource[resource_type]
	# just use alternative scene for each resource
	#_instance.get_node("Sprite2D").self_modulate = ResourceObject.get_resource_type_color(resource_type)
	var level_controller = LevelController.get_level_controller()

	position = _parent.to_position(coords)
#
	#var animation_player = _instance.get_node("AnimationPlayer") 
	#animation_player.play("start_animation")

	add_child(_instance)
	# does not work as expected, is not moving off screen resources, 
	# only when last position is visible again
	#var screen_enabler: = VisibleOnScreenEnabler2D.new()
	#screen_enabler.rect = Rect2(-10, -10, 20, 20)
	#add_child(screen_enabler)

	_controller = ResourceBallController.new(_model)
	add_child(_controller)
	#_controller.process_mode = Node.PROCESS_MODE_ALWAYS

func _state_changed(change):
	# TODO: return to pool
	if change.curr == ModelObject.State.Removed:
		_instance.queue_free()
		#_controller.queue_free()
		queue_free()
