class_name WindControllerComponent extends ViewComponent

var wind: WindController

func _ready() -> void:
	# Wind controller - wind speed and direction
	wind = WindController.new()
	wind.name = "WindController"
	add_child(wind)
