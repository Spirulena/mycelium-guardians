extends PanelContainer

@export var parent: Node

@onready var zoom_in_button : TextureButton = %"zoom_in_button"
@onready var zoom_out_button : TextureButton = %"zoom_out_button"
@onready var zoom_reset_button : TextureButton = %"zoom_reset_button"


func _ready():
	zoom_in_button.pressed.connect(func():
		parent.view_changed.emit({
			'type': 'Zoom',
			'prev': null,
			'curr': "in",
		})
	)
	zoom_out_button.pressed.connect(func():
		parent.view_changed.emit({
			'type': 'Zoom',
			'prev': null,
			'curr': "out",
		})
	)
	zoom_reset_button.pressed.connect(func():
		parent.view_changed.emit({
			'type': 'Zoom',
			'prev': null,
			'curr': "reset",
		})
	)
