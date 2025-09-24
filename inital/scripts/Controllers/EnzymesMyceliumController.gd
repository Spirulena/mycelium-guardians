class_name EnzymesMyceliumController extends Node2D

var _lc: LevelController
var _timer: Timer

func _init(level_controller):
	_lc = level_controller
	name = "EnzymesMyceliumController"

func _ready() -> void:
	_timer = Timer.new()
	_timer.wait_time = 1
	_timer.autostart = true
	_timer.name = "Tick"
	_timer.timeout.connect(_on_timer_timeout)
	add_child(_timer)

func _on_timer_timeout():
	calculate_enzymes()

func calculate_enzymes():
	# Have a rules list,
	# That can have custom resource added to calculate that

	# Apply enzyme production and adjust energy
	_lc.change_enzymes_amount(0)
	_lc.change_energy(-0)
