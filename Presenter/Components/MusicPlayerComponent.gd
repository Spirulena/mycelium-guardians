class_name MusicPlayerComponent extends ViewComponent

@onready var music

func _ready() -> void:
	y_sort_enabled = true
	z_index = 0
	z_as_relative = true

	# TODO: Can change the loaded sound scene into ViewComponent
	music = Loader.get_loader().return_scene("sound").instantiate()
	add_child(music)
