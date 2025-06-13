class_name StructurePlacingRadiusComponent extends ViewComponent

@onready var structure_placing_radius: StructurePacingRadius

func _ready() -> void:
	z_index = 0
	z_as_relative = false
	y_sort_enabled = true
	# Can build here tile map
	# Structure placing radius
	structure_placing_radius = Loader.get_loader().return_scene("isometric_rectangle").instantiate()
	structure_placing_radius.name = "StructurePlacingRadius"
	structure_placing_radius.hide()
	structure_placing_radius.z_index = 60
	structure_placing_radius.z_as_relative = false
	add_child(structure_placing_radius)

func handle_view_change(change: Dictionary):
	if super.handle_view_change(change):
		return

	if (change.type == GUIController.Actions.GrowStructure):
		if change.state == 'selected':
			if change.radius > 0:
				structure_placing_radius.set_effect_radius(_lc.get_coords_in_circle(Vector2i.ZERO, change.radius))
				structure_placing_radius.show_effect_radius()

		elif change.state == 'change_radius':
			structure_placing_radius.set_effect_radius(_lc.get_coords_in_circle(Vector2i.ZERO, change.radius))

		elif change.state == 'moving':
			if is_instance_valid(change.instance):
				if change.radius > 0:
					structure_placing_radius.position = _view.to_position(change.coords)
					structure_placing_radius.show_effect_radius()

		elif  change.state == 'place_not_allowed':
			structure_placing_radius.blink_failed()

		elif  change.state == 'lack_resources':
			structure_placing_radius.blink_failed()
			print_debug("Not enough resources to grow")

		elif change.state == 'placed':
			structure_placing_radius.hide_effect_radius()

		elif change.state == 'cancelled':
			structure_placing_radius.hide_effect_radius()
