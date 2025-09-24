extends Button
@onready var circle_04 = %Circle04

@onready var key_shortcut = %key_shortcut

func set_shortcut_key(key_string: String):
	key_shortcut.text = key_string

func highlight():
	circle_04.show()

func unhighlight():
	circle_04.hide()
