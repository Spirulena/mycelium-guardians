class_name PlantsComponent extends ViewComponent

@onready var plants_container

func _ready() -> void:
	y_sort_enabled = true
	z_index = 0
	z_as_relative = false

	# TODO: can remove container, component is the container

	# TODO: Grass needs to be lower then moths
	# Was called "Vegetation"
	plants_container = Node2D.new()
	plants_container.name = "Plants"
	plants_container.add_to_group("Plants")
	plants_container.y_sort_enabled = true
	plants_container.z_index = 60
	plants_container.z_as_relative = false
	add_child(plants_container)


func handle_model_change(change: Dictionary):
	if super.handle_model_change(change):
		return

	if change.type == ModelObject.Type.Plant:
		if change.prev == null:
			plants_container.add_child(PlantMapPresenter.new(change.curr, _view))
