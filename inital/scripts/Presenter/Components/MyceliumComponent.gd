class_name MyceliumComponent extends ViewComponent

func _ready() -> void:
	y_sort_enabled = true
	z_index = 20
	z_as_relative = true

func handle_view_change(change: Dictionary):
	if super.handle_view_change(change):
		return

	if (change.type == GUIController.Actions.Thicken):
		if change.state == 'request':
			pass
			var tile: = _lc.get_tile_at(change.coords)

			if tile.is_mycelium() and tile.get_mycelium().get_type() == ModelObject.Type.Mycelium:
				var mycelium: = tile.get_mycelium() as MyceliumObject
				mycelium.thicken() # ??

func handle_model_change(change: Dictionary):
	if super.handle_model_change(change):
		return

	# New Mycelium Queue, growing, mycelium_idle
	if change.type == ModelObject.Type.MyceliumQueue:
		# New
		if change.prev == null and change.curr != null:
			add_child(MyceliumQueueMapPresenter.new(change.curr, _view))

	elif change.type == ModelObject.Type.MyceliumGrowing:
		# New
		if change.prev == null and change.curr != null:
			add_child(MyceliumGrowingMapPresenter.new(change.curr, _view))

	elif change.type == ModelObject.Type.Mycelium:
		# New
		if change.prev == null:
			add_child(MyceliumMapPresenter.new(change.curr, _view))

		elif change.curr == null:
			# Move to sounds components ?
			_view.play_sound(SfxPlayer.SFX.prune)
