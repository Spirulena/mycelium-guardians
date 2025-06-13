class_name PathsTimerComponent extends ViewComponent

@onready var paths_timer: Timer

func _ready() -> void:
	y_sort_enabled = true
	z_index = 0
	z_as_relative = true

	# TODO: can remove container, component is the container

	paths_timer = Timer.new()
	paths_timer.name = "PathsTimer"
	paths_timer.timeout.connect(func(): _lc.paths_computer.update_if_requested())
	add_child(paths_timer)
	paths_timer.start()
