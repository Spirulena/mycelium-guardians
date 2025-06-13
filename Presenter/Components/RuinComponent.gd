class_name RuinComponent extends ViewComponent

@onready var ruin_container: Node2D
@onready var tile_selection

func _ready() -> void:
	y_sort_enabled = true
	z_index = 0
	z_as_relative = true

	# ruin_container
	ruin_container = Node2D.new()
	ruin_container.name = "Ruins"
	ruin_container.add_to_group("Ruins")
	ruin_container.y_sort_enabled = true
	ruin_container.z_index = 60
	ruin_container.z_as_relative = false
	add_child(ruin_container)

	# TMP: For highlighting that can connect mycelium to ruins
	# Tile selection
	tile_selection = Loader.get_loader().return_scene("LegacyTileSelection").instantiate()
	tile_selection.z_index = 60
	tile_selection.z_as_relative = false
	add_child(tile_selection)

func handle_view_change(change):
	if super.handle_view_change(change):
		return

	# Mycelium expand, preview, separate presenter ?
	if (change.type  == GUIController.Actions.Explore):
		if change.state == 'cancelled':
			tile_selection.clear_all()
		elif change.state == 'started':
			tile_selection.clear_all()
			# get all ruin presenters
			for child in ruin_container.get_children():
				if child is RuinMapPresenter:
					var model = child._model
					tile_selection.highlight_ruin(model)
			pass
		elif change.state == 'moving':
			pass
			for tile_coords in change.tiles:
				pass # check nearest ?
		elif change.state == 'placed':
			tile_selection.clear_all()

func handle_model_change(change: Dictionary):
	if super.handle_model_change(change):
		return

	if change.type == ModelObject.Type.Ruin:
		if change.prev == null:
			# Where is Ruins controller.
			var connection_controller = ConnectionController.new(change.curr)
			connection_controller.connected.connect(_ruin_touched)
			# save ruin reference in component ?
			ruin_container.add_child(RuinMapPresenter.new(change.curr, _view, connection_controller))
		if change.curr == null:
			print_debug("TODO: remove ruin - ", change)

func _ruin_touched(ruin, coords):
	# Reemit in view ? or model so that we can use it in tutorial
	print_debug("Ruin ", ruin, " touched at ", coords)
	# where to keep state that the windows was already displayed ?
	# TODO: commenting out for NExtfext
	_gui.ruin_touched(ruin, coords)
	# TODO: add button on top for actions, decompose
	# then we can based on that show the buttons
