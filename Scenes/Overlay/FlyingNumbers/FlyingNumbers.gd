extends Node2D

@export var label_scene: PackedScene
var queue: Dictionary
var tick: Timer
var container: Node2D

func _ready():
	container = Node2D.new()
	add_child(container)
	_init_ongoing_timer()
	#
	#Events.structure_output_added.connect(_on_structure_output_added)
	#Events.toggle_resource_output_labels.connect(_on_toggle_resource_output_labels)

func _on_toggle_resource_output_labels():
	container.visible = ! container.visible
	
func _on_structure_output_added(type, speed_adjusted_output, instance_id, grid_index):
	pass
	# spawn label
	if not is_instance_id_valid(instance_id):
		return
	var instance = instance_from_id(instance_id)
	if not is_instance_valid(instance):
		return
	var building_type = instance.building_enum
	# get in spawner, the structure top
	if not queue.has(instance_id):
		queue[instance_id] = []
	queue[instance_id].append([type,speed_adjusted_output, grid_index, building_type])
#	spawn_resource_trade_cost(type,speed_adjusted_output, grid_index, building_type)

func handle_queue():
	if queue.is_empty():
		tick.start()
	var amount_of_objects = queue.size()
#	if amount_of_objects == 0:
#		amount_of_objects = 1
#	var wait_time:float = 1.0 / float(amount_of_objects)
	for instance_id in queue.keys():
		if queue[instance_id].is_empty():
			continue
#		var elements = queue[instance_id].size()
#		if elements == 0:
#			elements = 1
		var args = queue[instance_id].pop_front()
		if not args:
			continue
#		spawn_resource_trade_cost(type,speed_adjusted_output, grid_index, building_type)
		spawn_resource_trade_cost.callv(args)
#		await get_tree().create_timer(float(wait_time) / float(amount_of_objects) / float(elements) ).timeout
#	tick.wait_time = float(wait_time)
	tick.start()

func spawn_resource_trade_cost(resource_type: ResourceObject.ResourceType, value: float, grid_index: int, building_type):
	if is_zero_approx(value):
		return
	var tile_global_position = get_structure_global_position(grid_index)
	var offset = BuildingObject.spawn_offset[building_type]
	var ui_global_position = tile_global_position + offset
	var instance = label_scene.instantiate()
	instance.global_position = ui_global_position
	instance.amount = value
	instance.resource_type = resource_type
	container.add_child(instance)

func get_structure_global_position(structure_grid_index: int):
	# if it is a building there
	# or if there is a history object id in the location
	# LevelPresenter aka LevelView have to_position method
	# TODO: this should be spawned by LevelView anyway
	return Vector2.ZERO

func _init_ongoing_timer():
	tick = Timer.new()
	tick.wait_time = 0.5
	tick.one_shot = true
	tick.timeout.connect(handle_queue)
	add_child(tick)
	tick.start()
