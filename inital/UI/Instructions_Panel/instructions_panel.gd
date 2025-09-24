extends Panel

@onready var confirm_button: Button = %"ConfirmButton"
@onready var title_label: RichTextLabel = %title
@onready var narrative_label: RichTextLabel = %narrative
@onready var instructions_label: RichTextLabel = %"instructions"
@onready var instructions_title: RichTextLabel = %"instructions_label"

var init_text = """[p]Explore surroundings by growing mycelium outward from the base, try reaching to one of these panels around you. Grow over them ... [/p]
[p]Use the [b]'explore'[/b] button, then paint on the map where you want mycelium to grow[/p]
[p]/use images and visual instructions, maybe like a combic book, and textures of actual objects/[/p]"""


func _ready():
	# zero
	_on_update_instructions("", "", "")
	visible = false
	confirm_button.pressed.connect(_on_confirm_button_pressed)

func _on_update_instructions(title: String, narrative: String, instructions: String):
	title_label.text = "[b]" + title + "[/b]"
	narrative_label.text = "[i]" + narrative + "[/i]"
	if instructions == "":
		instructions_title.visible = false
	else:
		instructions_title.visible = true
	instructions_label.text = "[code]" + instructions + "[/code]"

func _on_show_instructions_panel():
	visible = true

func _on_confirm_button_pressed():
	visible = false
