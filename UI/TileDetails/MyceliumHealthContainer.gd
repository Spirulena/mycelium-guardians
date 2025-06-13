extends VBoxContainer

@onready var heal_button: Button = $HealthContainer/MyceliumHealButton

@export var parent: Node
var _current_tile

func _ready():
	#parent.register_component(self)
	heal_button.pressed.connect(_on_heal_button_pressed)

func _on_heal_button_pressed():
	# TODO: ask boran how to propagate change to Model.
	if _current_tile != null:
		LevelController.get_level_controller().heal_tile(_current_tile.get_coords())

func _health_changed(change):
	if change.prop == 'health':
		update_health_display(change.curr)

func update_health_display(health):
	if health < 100:
		heal_button.show()
	else:
		heal_button.hide()

	$HealthContainer/MyceliumHealthProgress.value = health

func update_tile(tile):
	var prev_tile = _current_tile
	var curr_tile = tile

	if prev_tile != null:
		var prev_mycelium = prev_tile.get_mycelium()
		if prev_mycelium != null:
			prev_mycelium.health_changed.disconnect(_health_changed)

	var curr_mycelium = tile.get_mycelium()
	if curr_mycelium != null:
		curr_mycelium.health_changed.connect(_health_changed)
		show()
		update_health_display(curr_mycelium.get_health())
	else:
		hide()

	_current_tile = curr_tile
