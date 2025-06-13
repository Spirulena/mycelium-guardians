class_name CreaturesComponent extends ViewComponent
## This only allows to react to new creature and adding a child, creature presenter
## TODO: need something, load level, emit changes.
@onready var creatures_container

func _ready() -> void:
	y_sort_enabled = true
	z_index = 0
	z_as_relative = true

	# TODO: can remove container, component is the container

	# Had "Birds"
	# TODO: will have to split the Z indexes,
	# Some are above buildings (Moths), some below
	creatures_container = Node2D.new()
	creatures_container.name = "Creatures"
	creatures_container.y_sort_enabled = true
	creatures_container.z_index = 60
	creatures_container.z_as_relative = false
	add_child(creatures_container)

func handle_model_change(change: Dictionary):
	if super.handle_model_change(change):
		return

	if change.type == ModelObject.Type.Creature:
		if change.prev == null:
			var subtype = change.curr.get_subtype()
			match subtype:
				CreatureObject.CreatureType.Worm:
					creatures_container.add_child(WormMapPresenter.new(change.curr, _view))
				CreatureObject.CreatureType.Moths:
					creatures_container.add_child(MothMapPresenter.new(change.curr, _view))
				CreatureObject.CreatureType.FFCrasher:
					creatures_container.add_child(FFCrasherMapPresenter.new(change.curr, _view))
