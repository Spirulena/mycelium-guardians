extends HBoxContainer

@export var parent: Node

@export var pause_icon: Texture2D
@export var unpause_icon: Texture2D
@onready var pause_production_button = $PauseProductionButton

func _ready():
	hide() # Not needed for now, nothing is producing
	#parent.register_component(self)

func update_tile(tile):
	var structure_object = tile.get_structure()
	if structure_object != null:
		# TODO: if is producing / active
		show()
		_update_production_pause_icon(true)
	else:
		hide()

# Events.pause_production_toggle.emit(1)

func _update_production_pause_icon(production_active_state):
	if production_active_state:
		pause_production_button.icon = pause_icon
		pause_production_button.text = "Producing "
	else:
		pause_production_button.icon = unpause_icon
		pause_production_button.text = "Dormant "
