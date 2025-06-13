class_name BuildingComponent extends ViewComponent

@onready var building_container

func _ready() -> void:
	z_index = 0
	z_as_relative = false
	y_sort_enabled = true
	building_container = Node2D.new()
	building_container.name = "Buildings"
	building_container.add_to_group("Buildings")
	building_container.y_sort_enabled = true
	building_container.z_index = 60
	building_container.z_as_relative = false
	add_child(building_container)

func handle_view_change(change: Dictionary):
	if super.handle_view_change(change):
		return

	if (change.type == GUIController.Actions.Thicken):
		if change.state == 'request':

			var instance = Label.new()
			instance.text = "Ticken Request %d,%d" % [change.coords.x, change.coords.y]
			instance.position = _view.to_position(change.coords)
			instance.z_index = 200
			instance.z_as_relative = false
			var tween: Tween = instance.create_tween()
			tween.tween_property(instance, "scale", Vector2(2, 2), 2).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
			tween.tween_callback(instance.queue_free)
			building_container.add_child(instance)

	if (change.type == GUIController.Actions.GrowStructure):
		if change.state == 'selected':
			var instance = Loader.get_loader().return_scene(change.curr).instantiate()
			instance.z_index = 72
			# Can disable to have structure in front when placing
			instance.y_sort_enabled = true
			instance.z_as_relative = false

			if change.curr == BuildingObject.StructureType.Absorber_Smog:
				instance.modulate = Global.gene_base_color

			# TODO: better way to distinguish preview when placing
			# from actually placing the structure on mycelium and world map
			instance.hide()
			# TODO: add to buildings group, so that we can hide them all
			change.store.call(instance)
			building_container.add_child(instance)
			if change.radius > 0:
				# preview cost
				instance.scale = BuildingObject.scale_size_by_radius[change.radius]
			building_container.z_index = 72
			# TODO: hide diegetic UI elements

		elif change.state == 'change_radius':
			# tween building preview to size
			if is_instance_valid(change.instance):
				var new_scale: Vector2 = BuildingObject.scale_size_by_radius[change.radius]
				var tween_s: Tween = change.instance.create_tween()
				tween_s.tween_property(change.instance, "scale", new_scale, 0.3).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN_OUT)

		elif change.state == 'moving':
			# Snap and tween the position, jumping to new location over time, rather then instant
			# When coords changed
			if is_instance_valid(change.instance):
				change.instance.show()
				change.instance.position = _view.to_position(change.coords)

		elif  change.state == 'lack_resources':
			pass

		elif change.state == 'place_request':
			# here so that can be intercepted and checked, with feedback provided
			# check cost first
			var cost = BuildingObject.get_growth_cost_static(change.building_id, change.radius)
			if not LevelController.get_level_controller().can_afford_growth_cost(cost):
				_view.view_changed.emit({
					'type': GUIController.Actions.GrowStructure,
					'state': 'lack_resources',
					'coords': change.coords,
					'instance': change.instance,
				})
			else:
				LevelController.get_level_controller().grow_structure_at_coords(change.building_id, change.coords, change.radius)
				_view.view_changed.emit({
					'type': GUIController.Actions.GrowStructure,
					'state': 'placed',
					'coords': change.coords,
					'instance': change.instance,
					})

		elif change.state == 'placed':
			# start Decay timer
			# show timer ?
			pass


		elif change.state == 'cancelled':
			if is_instance_valid(change.instance):
				change.instance.queue_free()
			building_container.z_index = 60 # have a call to revert to default, or variable

func handle_model_change(change: Dictionary):
	if super.handle_model_change(change):
		return

	if change.type == ModelObject.Type.Building:
		if change.prev == null:
			# New building
			building_container.add_child(BuildingMapPresenter.new(change.curr, _view))

# TODO: should rather use building spawning logic.
func spawn_base(coords: Vector2i):
	var instance = Loader.get_loader().return_scene("base").instantiate()
	instance.grid_position = coords
	instance.position = _view.to_position(coords)
	instance.size = Vector2i(3, 3) # is this not defined in vuilding class
	get_tree().get_first_node_in_group("Buildings").add_child(instance)
