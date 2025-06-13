extends Button
@export var parent: Node
func _ready():
	hide() # not used yet
	#parent.register_component(self)
	#pressed.connect(_on_button_pressed)

func update_tile(tile):
	pass

func _on_button_pressed():
	print_debug("TODO: Recycle structure")
