extends Node2D
class_name GameplayPresenter

enum Action {
	SELECT,
	GROW_MYCELIUM,
	GROW_BUILDING,
	ONE,
	TWO,
	THREE
}

@export
var action_selection: UIActionSelection

@export
var selection_info_presenter: SelectionInfoPresenter

var _main_map_presenter: MainMapPresenter

func set_main_map_presenter(presenter: MainMapPresenter) -> void:
	self._main_map_presenter = presenter

# Called when the node enters the scene tree for the first time.
func _ready():
	action_selection.selection_changed.connect(func (prev, curr): _main_map_presenter.set_action(curr))
	_main_map_presenter.selection_changed.connect(selection_info_presenter.on_selection_changed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
