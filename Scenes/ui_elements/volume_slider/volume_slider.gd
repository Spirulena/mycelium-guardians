extends HSlider
@onready var audio_server = AudioServer
@export var bus_name: String

@onready var bus_index: int

func _ready() -> void:
	bus_index = audio_server.get_bus_index(bus_name)
	value = db_to_linear(
		audio_server.get_bus_volume_db(bus_index)
	)
	value_changed.connect(_on_value_changed)
	visibility_changed.connect(_on_visibility_changed)

func _on_visibility_changed():
	bus_index = audio_server.get_bus_index(bus_name)
	value = db_to_linear(
		audio_server.get_bus_volume_db(bus_index)
	)

func _on_value_changed(slider_value: float) -> void:
#	audio_server.set_bus_volume_db(AudioServer.get_bus_index("music"), 0)
#	AudioManager.set_bus_volume_db(
#		linear_to_db(slider_value),
#		bus_index,
#	)
	audio_server.set_bus_volume_db(
		audio_server.get_bus_index(bus_name),
		linear_to_db(slider_value)
	)
