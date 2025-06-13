class_name OverlaysViewComponent extends ViewComponent

var mycelium_health_overlay
var smog_overlay
var radiation_overlay
var water_overlay
var water_storage_overlay
var energy_storage_overlay
var minerals_storage_overlay
var carbon_storage_overlay
var _overlay_state: Dictionary

func _ready() -> void:
	_overlay_state = {
		'current_overlay': null,
		'last_user_overlay': null,
		'is_auto': false
	}

	# Overlays
	mycelium_health_overlay = Loader.get_loader().return_scene("mycelium_health_overlay").instantiate()
	mycelium_health_overlay.z_index = 70
	mycelium_health_overlay.z_as_relative = false
	add_child(mycelium_health_overlay)
	smog_overlay = Loader.get_loader().return_scene("smog_overlay").instantiate()
	smog_overlay.z_index = 70
	smog_overlay.z_as_relative = false
	add_child(smog_overlay)
	radiation_overlay = Loader.get_loader().return_scene("radiation_overlay").instantiate()
	radiation_overlay.z_index = 70
	add_child(radiation_overlay)
	water_overlay = Loader.get_loader().return_scene("water_overlay").instantiate()
	water_overlay.z_index = 70
	add_child(water_overlay)
	water_storage_overlay = Loader.get_loader().return_scene("water_storage_overlay").instantiate()
	water_storage_overlay.z_index = 70
	add_child(water_storage_overlay)
	energy_storage_overlay = Loader.get_loader().return_scene("energy_storage_overlay").instantiate()
	energy_storage_overlay.z_index = 70
	add_child(energy_storage_overlay)
	minerals_storage_overlay = Loader.get_loader().return_scene("minerals_storage_overlay").instantiate()
	minerals_storage_overlay.z_index = 70
	add_child(minerals_storage_overlay)
	carbon_storage_overlay = Loader.get_loader().return_scene("carbon_storage_overlay").instantiate()
	carbon_storage_overlay.z_index = 70
	add_child(carbon_storage_overlay)

func handle_view_change(change):
	if super.handle_view_change(change):
		return

	if (change.type == 'Overlay'):
		process_view_change(change)

	elif (change.type == GUIController.Actions.GrowStructure):
		if change.state == 'selected':
			show_overlay_on_building_id(change.curr, true)
		elif change.state == 'cancelled':
			if change.instance != null:
				clear_overlay(true)
	elif (change.type  == GUIController.Actions.Explore):
		if change.state == 'cancelled':
			pass
			#print("OverlaysViewC ", change)
			clear_overlay(true) #WATERAUTO
		elif change.state == 'started':
			#print("OverlaysViewC started", change)
			set_overlay(Overlay.OverlayType.Water, true) #WATERAUTO
		elif change.state == 'placed':
			clear_overlay(true) #WATERAUTO

# Function to set an overlay
func set_overlay(overlay_type: Overlay.OverlayType, is_auto: bool):
	if not is_auto:
		_overlay_state.last_user_overlay = overlay_type  # Remember last user selection
	_overlay_state.current_overlay = overlay_type
	_overlay_state.is_auto = is_auto
	update_overlay_visibility()

# Function to clear the current overlay, with an option to restore the user's last choice
func clear_overlay(restore_user_last: bool = true):
	if restore_user_last and _overlay_state.is_auto and _overlay_state.last_user_overlay != null:
		# Restore to the last user-selected overlay if the current overlay was set automatically
		set_overlay(_overlay_state.last_user_overlay, false)
	else:
		_overlay_state.current_overlay = null
		_overlay_state.is_auto = false
		update_overlay_visibility()

func update_overlay_visibility():
	# Initially hide all overlays
	smog_overlay.hide_overlay()
	radiation_overlay.hide_overlay()
	water_overlay.hide_overlay()
	water_storage_overlay.hide_overlay()
	energy_storage_overlay.hide_overlay()
	minerals_storage_overlay.hide_overlay()
	carbon_storage_overlay.hide_overlay()

	# Show the current overlay if one is set
	match _overlay_state.current_overlay:
		Overlay.OverlayType.MyceliumHealth:
			mycelium_health_overlay.show_overlay()
		Overlay.OverlayType.Smog:
			smog_overlay.show_overlay()
		Overlay.OverlayType.Radiation:
			radiation_overlay.show_overlay()
		Overlay.OverlayType.Water:
			water_overlay.show_overlay()
		Overlay.OverlayType.WaterStorage:
			water_storage_overlay.show_overlay()
		Overlay.OverlayType.EnergyStorage:
			energy_storage_overlay.show_overlay()
		Overlay.OverlayType.MineralsStorage:
			minerals_storage_overlay.show_overlay()
		Overlay.OverlayType.CarbonStorage:
			carbon_storage_overlay.show_overlay()

	#print_debug("update_overlay_visibility")
	#print_stack()
	_gui.view_changed.emit({
		'prev': null,
		'curr': null,
		'type': 'Overlay',
		'overlay_type': _overlay_state.current_overlay,
		'is_auto': false,
	})

func hide_user_selected_overlay():
	if not _overlay_state.is_auto:
		# The current overlay was set by the user, so clear it without restoring
		_overlay_state.last_user_overlay = null
		_overlay_state.current_overlay = null
		_overlay_state.is_auto = false  # Reset the flag as a precaution
		update_overlay_visibility()
	# If the current overlay was set automatically, this function does nothing

func process_view_change(change: Dictionary):
	if change.type == 'Overlay' and change.overlay_type == Overlay.OverlayType.All and not change.curr:
		hide_user_selected_overlay()
	# Other cases remain as they are
	elif change.curr == true:
		# show
		set_overlay(change.overlay_type, change.is_auto)
	elif change.curr == false:
		clear_overlay(false)

# Building type -> overlay
# show, hide
var last_overlay
func show_overlay_on_building_id(building_id: BuildingObject.StructureType, _show: bool = false):
	if not _show: # hide all
		_gui.view_changed.emit({
			'prev': null,
			'curr': _show,
			'type': 'Overlay',
			'overlay_type': Overlay.OverlayType.All,
			'is_auto': true,
		})
		return true

	var overlay_type: Overlay.OverlayType = Overlay.OverlayType.None
	match building_id:
		BuildingObject.StructureType.Absorber_Radiation:
			overlay_type = Overlay.OverlayType.Radiation
		BuildingObject.StructureType.Absorber_Smog:
			overlay_type = Overlay.OverlayType.Smog
		BuildingObject.StructureType.Storage_Water:
			overlay_type = Overlay.OverlayType.WaterStorage
		BuildingObject.StructureType.Storage_Energy:
			overlay_type = Overlay.OverlayType.EnergyStorage
		BuildingObject.StructureType.Storage_Minerals:
			overlay_type = Overlay.OverlayType.MineralsStorage
		BuildingObject.StructureType.Storage_Carbon:
			overlay_type = Overlay.OverlayType.CarbonStorage

	# No match == don't show
	if overlay_type == Overlay.OverlayType.None:
		return false

	var change: Dictionary = {
		# how should I query the current state aka. prev
		'prev': null,
		'curr': _show,
		'type': 'Overlay',
		'overlay_type': overlay_type,
		'is_auto': true,
	}
	_gui.view_changed.emit(change)
	return true
