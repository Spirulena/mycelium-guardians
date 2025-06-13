extends HBoxContainer

@export var parent: Node

@export var pause_icon: Texture2D
@export var unpause_icon: Texture2D
@onready var pause_growth_button = $PauseGrowthButton

func _ready():
	parent.register_component(self)

func update_tile(tile):
	var structure_object = tile.get_structure()
	if structure_object != null:
		# TODO: if is growing
		show()
		#self.visible = current_instance.growing
		#growth_progress.value = current_instance.calculated_growth_status * 100.0
	else:
		# not growing
		hide()

func _update_pause_icon(tile):
	if tile.pause_growth:
		pause_growth_button.icon = unpause_icon
	else:
		pause_growth_button.icon = pause_icon

# Events.toggle_pause_structure_growth.emit(1)
