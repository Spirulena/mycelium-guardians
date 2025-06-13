class_name ResourceFoundComponent extends ViewComponent

#@onready var harvest_ui_container
#var coords_to_harvest_ui_element

func _ready() -> void:
	y_sort_enabled = true
	z_index = 60
	z_as_relative = false

	#harvest_ui_container = Node2D.new()
	#harvest_ui_container.name = "HarvestUIElements"
	#harvest_ui_container.y_sort_enabled = true
	#harvest_ui_container.z_index = 200
	#harvest_ui_container.z_as_relative = false
	#add_child(harvest_ui_container)
	#coords_to_harvest_ui_element = {}

# Note: We do not have noise map with resources.
# And not button to dig
# Think how the UI for that would work. (Dig) ?. Mycelium dig entry ?

func _resource_found_by_mycelium(level_controller, resources_at_mycelium):
	var instance = Loader.get_loader().return_scene("resource_found_animation").instantiate()
	var coords = resources_at_mycelium.get_coords()
	instance.name = "resource_found_instance_%d_%d" % [coords.x, coords.y]
	instance.type = resources_at_mycelium.get_resource_type()
	instance.position = _view.to_position(resources_at_mycelium.get_coords())
	add_child(instance)
	#for resource in resources_at_mycelium:
		#instance.finished.connect(func (): _view._add_harvest_ui_element(resource))

func handle_model_change(change: Dictionary):
	if super.handle_model_change(change):
		return

	if change.type == ModelObject.Type.Mycelium:
		if change.prev == null:
			var resource_at_tile = _lc.get_tile_at(change.coords).get_resource()
			if resource_at_tile != null:
				pass
				# NOTE: Disabled showing resource found and harvest UI element
				_resource_found_by_mycelium(_lc, resource_at_tile)


# Model change stuff for harvest UI element
		#if change.type == ModelObject.Type.Mycelium:
			#if change.prev == null:
				#var resource_at_tile = level_controller.get_tile_at(change.coords).get_resource()
				#if resource_at_tile != null:
					#pass
					## NOTE: Disabled showing resource found and harvest UI element
					##_resource_found_by_mycelium(level_controller, resources_at_mycelium)
#
				#mycelium_container.add_child(MyceliumMapPresenter.new(change.curr, self))
				#sfx.play_sfx_type(SfxPlayer.SFX.expand)
#
			#elif change.curr == null:
				## Harvest UI element delete
				#if coords_to_harvest_ui_element.has(change.coords):
					## will animate and queue free
					#coords_to_harvest_ui_element[change.coords].remove()
					#coords_to_harvest_ui_element.erase(change.coords)
				#sfx.play_sfx_type(SfxPlayer.SFX.prune)
#
		#elif change.type == ModelObject.Type.Harvester:
			#if change.prev == null:
				## Handle UI button
				#if coords_to_harvest_ui_element.has(change.coords):
					#var harvest_ui_element = coords_to_harvest_ui_element[change.coords]
					## Harvesting will queue free after animation
					#sfx.play_sfx_type(SfxPlayer.SFX.harvest)
					#harvest_ui_element.harvesting()
#
					#if coords_to_harvest_ui_element.has(change.coords):
						#coords_to_harvest_ui_element.erase(change.coords)
#
				#add_child(HarvesterMapPresenter.new(change.curr, self))



#func _add_harvest_ui_element(resource: ResourceObject):
	#var instance = Loader.get_loader().return_scene("harvest_ui_element").instantiate()
	#instance.coords = resource.get_coords()
	#instance.name = "harvest_ui_element_%d_%d" % [instance.coords.x, instance.coords.y]
	#instance.type = resource.get_resource_type()
	#instance.position = _view.to_position(instance.coords)
	#instance.clicked.connect(self._harvest_from_coords)
	#harvest_ui_container.add_child(instance)
	#if instance.has_method("animate"):
		#instance.animate()
#
	#coords_to_harvest_ui_element[instance.coords] = instance
