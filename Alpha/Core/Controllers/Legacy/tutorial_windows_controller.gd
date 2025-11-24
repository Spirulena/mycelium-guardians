extends Node2D

# Tutorial windows
@export var tutorial_instructions_window: PackedScene
@onready var tutorial_window_instance
func _ready():
	pass
	#Events.set_tutorial_instructions_window.connect(_on_set_tutorial_instructions_window)

# Tutorial UI windows

func _on_set_tutorial_instructions_window(text: String, title: String, state_name: String = "blank", instruction_text: String = ""):
	spawn_tutorial_instructions_window(text, title, state_name, instruction_text)


func spawn_tutorial_instructions_window(text: String, title: String, state_name: String, instruction_text):
	if not is_instance_valid(tutorial_window_instance):
		tutorial_window_instance = tutorial_instructions_window.instantiate()
		get_tree().get_first_node_in_group("gui").add_child(tutorial_window_instance)
	tutorial_window_instance.set_title_text(title, text)
	tutorial_window_instance.set_gif(state_name)
	var instructions = instruction_text.split(". ")
	instruction_text = ""
	for instruction in instructions:
		if instruction.is_empty():
			continue
		instruction_text += "[ul]%s[/ul]" % instruction
	tutorial_window_instance.set_instructions(instruction_text)
