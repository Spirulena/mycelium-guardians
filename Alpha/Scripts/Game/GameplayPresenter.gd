extends Node2D
class_name GameplayPresenter

enum Action { SELECT, GROW_MYCELIUM }

var _main_map_presenter: MainMapPresenter

func set_main_map_presenter(presenter: MainMapPresenter) -> void:
	self._main_map_presenter = presenter

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event: InputEvent):
	if not _main_map_presenter:
		return

	if event.is_action_released("mycelium_grow"):
		_main_map_presenter.set_action(Action.GROW_MYCELIUM)
