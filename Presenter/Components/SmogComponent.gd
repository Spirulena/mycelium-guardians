class_name SmogComponent extends ViewComponent

func _ready() -> void:
	# add_to_group("Smog")
	y_sort_enabled = true
	z_index = 70
	z_as_relative = true

func handle_view_change(change: Dictionary):
	if super.handle_view_change(change):
		return # exit if superclass ignored the change

	if (change.type == GUIController.Actions.GrowStructure):
		if change.state == 'selected':
			var a_tween: Tween = self.create_tween()
			a_tween.tween_property(self, "modulate:a", 0.4, 0.2).from(1.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
		elif change.state == 'cancelled':
			modulate.a = 1.0

	# Include radiation ?
	# or just when placing any structure just hide smog ?
	# Then when no longer doing it show back up
	#if change.type == 'Overlay' and change.overlay_type == Overlay.OverlayType.Smog:
		#if change.curr == true:
			#var a_tween: Tween = self.create_tween()
			#a_tween.tween_property(self, "modulate:a", 0.4, 0.2).from(1.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	#elif change.type == 'Overlay':
		#if change.overlay_type != Overlay.OverlayType.Smog:
			#modulate.a = 1.0
	##elif change.type == 'Overlay' and change.overlay_type == Overlay.OverlayType.None:

func handle_model_change(change: Dictionary):
	if super.handle_model_change(change):
		return # exit if superclass ignored the change

	if change.type == 'TileObject' and change.prev == null:
		if not change.curr.have_smog_presenter():
			add_child(SmogTilePresenter.new(change.curr, _view))
