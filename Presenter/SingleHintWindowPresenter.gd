class_name SingleHintWindowPresenter extends PanelContainer

@onready var label: Label = $MarginContainer/VBoxContainer/Label
@onready var check_button: CheckButton = $MarginContainer/VBoxContainer/HBoxContainer/CheckButton
@onready var button: Button = $MarginContainer/VBoxContainer/HBoxContainer/Button

var _hint_key: String
var _show_again: bool

signal ok_pressed

func set_hint_text(hint_text: String):
	label.text = hint_text

func set_hint_key(hint_key: String):
	_hint_key = hint_key

func set_show_again(show_again: bool):
	_show_again = show_again
	check_button.visible = _show_again

func _ready():
	check_button.toggled.connect(func(toggled:bool ): _show_again = !toggled)
	button.pressed.connect(_on_button_pressed)

func _on_button_pressed():
	# emit change, via controller.
	# connect in gui controller ?
	ok_pressed.emit(_hint_key)
	print_debug(_hint_key)
	pass
