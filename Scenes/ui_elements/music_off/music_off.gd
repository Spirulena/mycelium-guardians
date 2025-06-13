extends TextureButton
#@onready var audio_server = AudioServer
var muted: bool = false

@export var icons: Array[Texture2D]
var current: float
# Called when the node enters the scene tree for the first time.
func _ready():
	pressed.connect(_on_button_pressed)
	set_icon(self.muted)
#	pressed.emit()

func set_icon(mute_state: bool):
	texture_normal = icons[int(mute_state)]

func _on_button_pressed():
	if muted:
		_on_UnmuteButton_pressed()
	else:
		_on_MuteButton_pressed()
	self.muted = !self.muted
	set_icon(self.muted)

func _on_MuteButton_pressed():
	current = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("pre_master"))

	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("pre_master"), -80)

func _on_UnmuteButton_pressed():
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("pre_master"), current)
