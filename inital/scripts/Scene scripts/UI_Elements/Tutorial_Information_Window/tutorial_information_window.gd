extends Control

@onready var title = %title
@onready var text = %text
@onready var instruction_text = %instruction_text

@onready var page_number: Label = %page_number
@onready var previous_button: Button = %previous_button
@onready var next_button: Button = %next_button
@onready var exit_tutorial_button: Button = %exit_tutorial_button

@onready var fold_button: Button = %FoldButton
@onready var un_fold_button: Button = %UnFoldButton

@onready var gif_panel = %gif_panel
@onready var panel_container: PanelContainer = %PanelContainer

var state_name = "who_we_are"

@onready var animated_sprite_2d_gif: AnimatedSprite2D = %AnimatedSprite2D_gif

func _ready():
	set_gif("BLANK")
	previous_button.pressed.connect(_on_previous_button_pressed)
	next_button.pressed.connect(_on_next_button_button_pressed)
	fold_button.pressed.connect(_on_fold_button_pressed)
	un_fold_button.pressed.connect(_on_un_fold_button_pressed)
	exit_tutorial_button.pressed.connect(_on_exit_tutorial_button)

	#Events.show_tutorial_window.connect(_on_show_tutorial_window)

func _on_show_tutorial_window():
	_on_un_fold_button_pressed()
	show()

# prev / next / exit tutorial
func _on_next_button_button_pressed():
	pass
	# TODO: hookup different way
	#Events.tutorial_next_page_requested.emit()
	# Events.tutorial_instructions_window_closed.emit()
	# queue_free()

func _on_previous_button_pressed():
	pass
	# TODO: hookup diff way
	#Events.tutorial_prev_page_requested.emit()

func _on_exit_tutorial_button():
	#Events.exit_tutorial_request.emit()
	hide()
	# Then can un-hide from pause menu

func set_title_text(title_string, text_string):
	title.text = title_string
	text.text = text_string

func set_instructions(instruction_string: String):
	instruction_text.text = instruction_string

func set_gif(gif_name: String):
	var animation_names = animated_sprite_2d_gif.sprite_frames.get_animation_names()
	if gif_name not in animation_names:
		gif_name = "BLANK"
	if gif_name == "BLANK":
		gif_panel.hide()
	else:
		gif_panel.show()
	animated_sprite_2d_gif.play(gif_name)

func _on_fold_button_pressed():
	panel_container.hide()
	un_fold_button.show()

func _on_un_fold_button_pressed():
	panel_container.show()
	un_fold_button.hide()
