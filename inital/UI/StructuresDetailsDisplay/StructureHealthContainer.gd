extends VBoxContainer

@onready var heal_button: Button = $HealthContainer/StructureHealButton

@export var parent: Node

func _ready():
	hide() # health not affected now
	#parent.register_component(self)
	#heal_button.pressed.connect(_on_heal_button_pressed)

func _on_heal_button_pressed():
	print_debug("TODO: hook me up")
	# TODO: emit change to model
	pass

func update_tile(tile):
	var structure_object = tile.get_structure()
	if structure_object != null:
		show()
		if structure_object.get_health() < 100:
			heal_button.show()
		else:
			heal_button.hide()

		$HealthContainer/StructureHealthProgress.value = structure_object.get_health()
	else:
		hide()
