class_name StorageAddedComponent extends ViewComponent

@onready var storage_added_container: Node2D

func _ready() -> void:
	y_sort_enabled = false
	z_index = 0
	z_as_relative = true

	storage_added_container = Node2D.new()
	storage_added_container.name = "StorageAddedContainer"
	storage_added_container.y_sort_enabled = true
	storage_added_container.z_index = 200
	storage_added_container.z_as_relative = false
	add_child(storage_added_container)

func handle_model_change(change: Dictionary):
	if super.handle_model_change(change):
		return

	if change.type == 'ResourceLimit':
		on_storage_added_from_structure(change)
		#_view.play_sound(SfxPlayer.SFX.storage_added) # TODO: add sound

func on_storage_added_from_structure(change):
	if change.object.get_type() == ModelObject.Type.Building:
		var _scene: Node2D = Loader.get_loader().return_scene("storage_added_scene").instantiate()
		_scene.name = "storage_added_scene_%d_%d" % [change.coords.x, change.coords.y]
		_scene.position = _view.to_position(change.coords)
		_scene.amount = change.change_amount
		_scene.resource_type = change.resource_type
		storage_added_container.add_child(_scene)
	elif change.object.get_type() == ModelObject.Type.Mycelium:
		pass # maybe something later
