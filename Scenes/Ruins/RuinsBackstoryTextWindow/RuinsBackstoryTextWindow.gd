extends Panel

@export var emit_history_confirmed: bool = true
signal history_confirmed
@onready var confirm_button: Button = %"history_confirm_button"

@export var text_start: String = ""
@export var text_end: String = "one constant is change..."
@export var text_size: int = 35

func _ready():
	if not text_start.is_empty():
		%RichTextLabel.text = text_start
	confirm_button.pressed.connect(on_confirm_button)
	%"RichTextLabel".add_theme_font_size_override("normal_font_size", text_size)

func on_confirm_button():
	hide()

	if emit_history_confirmed:
		history_confirmed.emit()
	queue_free()

func update_end_text():
	%"RichTextLabel".text = text_end
