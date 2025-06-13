class_name MyceliumPreviewComponent extends ViewComponent

@onready var mycelium_preview_container

func _ready() -> void:
	# Sorted by Z index
	mycelium_preview_container = Node2D.new()
	mycelium_preview_container.name = "MyceliumPreviewContainer"
	mycelium_preview_container.y_sort_enabled = true
	mycelium_preview_container.z_index = 200
	mycelium_preview_container.z_as_relative = false
	add_child(mycelium_preview_container)

func handle_view_change(change):
	if super.handle_view_change(change):
		return

	# TODO: handle blockades
	# See: 'PlaceMyceliumPathDefaultComponent'

	# Mycelium expand, preview, separate presenter ?
	if (change.type  == GUIController.Actions.Explore):
		if change.state == 'cancelled':
			mycelium_preview_canceled(change)
				# TODO: add some dissolve effect
		elif change.state == 'started':
			pass
		elif change.state == 'moving':
			for child in mycelium_preview_container.get_children():
				child.queue_free()

			for tile_coords in change.tiles:
				var instance = Loader.get_loader().return_scene("MyceliumPreview").instantiate()
				instance.modulate = Color.GREEN_YELLOW
				instance.name = "mycelium_preview_tile_%d_%d" % [tile_coords.x, tile_coords.y]
				instance.coords = tile_coords

				instance.position = _view.to_position(tile_coords)
				mycelium_preview_container.add_child(instance)
		elif change.state == 'placed':
			mycelium_preview_placed(change)

func mycelium_preview_placed(change):
	#for child in mycelium_preview_container.get_children():
		#child.queue_free()
	if change.tiles.size() > 0:
		# Animate queue free
		var i: int = 0
		var time: float = 0.09
		var c = Color(0.3, 0.5, 0.1, 0.5)
		var offset =  change.tiles.size() * (time)
		for child in mycelium_preview_container.get_children():
			var tween: Tween = child.create_tween()
			tween.tween_property(child, "modulate", c, time+0.1).set_delay(float(i)*time).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BOUNCE)
			#tween.tween_callback(child.queue_free)
			#child.queue_free()
			i+=1
		i = 0
		time = 0.12
		#c = Color(1.0, 1.0, 0.0, 0.0)
		for child in mycelium_preview_container.get_children():
			var tween: Tween = child.create_tween()
			tween.tween_property(child, "modulate:a", 0.0, time).set_delay(offset + float(i)*time).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)
			tween.tween_callback(child.queue_free)
			#child.queue_free()
			i+=1

func mycelium_preview_canceled(change):
	if change.tiles.size() > 0:
		# Animate queue free
		var i: int = 0
		var time: float = 0.05
		var c = Color(1.0, 0.0, 0.0, 0.0)
		for child in mycelium_preview_container.get_children():
			var tween: Tween = child.create_tween()
			tween.tween_property(child, "modulate", c, time+0.1).set_delay(float(i)*time).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BOUNCE)
			tween.tween_callback(child.queue_free)
			#child.queue_free()
			i+=1
