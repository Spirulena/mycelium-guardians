class_name CanBuildHereComponent extends ViewComponent

@onready var can_build_here_tile_map: CanBuildHereTileMap

func _ready() -> void:
	z_index = 0
	z_as_relative = false
	y_sort_enabled = true
	# Can build here tile map
	can_build_here_tile_map = Loader.get_loader().return_scene("CanBuildHereTileMap").instantiate()
	can_build_here_tile_map.z_index = 71
	can_build_here_tile_map.z_as_relative = true
	can_build_here_tile_map.y_sort_enabled = true
	can_build_here_tile_map.hide()
	can_build_here_tile_map.set_process(false)
	add_child(can_build_here_tile_map)
	#can_build_here_tile_map.set_timer(false)


func handle_view_change(change: Dictionary):
	if super.handle_view_change(change):
		return

	if (change.type == GUIController.Actions.GrowStructure):
		if change.state == 'selected':
			if change.radius > 0:
				pass
			#can_build_here_tile_map.set_process(true)
			#can_build_here_tile_map.set_timer(true)
			draw_after()
			can_build_here_tile_map.show()
		elif change.state == 'change_radius':
			pass
		elif change.state == 'moving':
			draw_after()
			pass
		elif  change.state == 'lack_resources':
			pass
		elif change.state == 'placed':
			pass
		elif change.state == 'cancelled':
			can_build_here_tile_map.hide()
			#can_build_here_tile_map.set_process(false)
			#can_build_here_tile_map.set_timer(false)

# TODO: could react to new MyceliumObject added in model and then force update, then I do not think we need the timer at all

func handle_model_change(change: Dictionary):
	if super.handle_model_change(change):
		return

	## New Mycelium Queue, growing, mycelium_idle
	#if change.type == ModelObject.Type.MyceliumQueue:
		## New
		#if change.prev == null and change.curr != null:
			#can_build_here_tile_map.draw_tile_map()
#
	#elif change.type == ModelObject.Type.MyceliumGrowing:
		## New
		#if change.prev == null and change.curr != null:
			#can_build_here_tile_map.draw_tile_map()

	if change.type == ModelObject.Type.Mycelium:
		# New
		draw_after()
		if change.prev == null:
			draw_after()
			#await get_tree().process_frame
			#can_build_here_tile_map.draw_tile_map()

		elif change.curr == null:
			# Move to sounds components ?
			draw_after()

func on_mycelium_state_changed():
	pass

func draw_after():
	#_lc.paths_computer.update_paths()
	#await get_tree().process_frame
	can_build_here_tile_map.draw_tile_map.call_deferred()
