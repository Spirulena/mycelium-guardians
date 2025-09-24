extends Button

func _ready():
	pressed.connect(_on_exit_pressed)

# TODO: can register and then from Pause Manu propegate to GUICOntroller
func _on_exit_pressed():
	get_tree().quit()
