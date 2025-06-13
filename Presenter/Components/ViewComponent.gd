class_name ViewComponent extends Node2D

var _lc: LevelController
var _view: LevelView
var _gui: GUIController

var _le: TileMapLayer # Move to separate class to handling getting and setting ?
var _le_smog

func _init(level_controller: LevelController, view: LevelView, gui: GUIController, component_name: String = '', args: Dictionary = {}):
	_lc = level_controller
	_view = view
	_gui = gui
	_le = _view.level_editor_tilemap

	name = component_name
	# Rise the issue, class_name ignored, base class returned, name = component_name if component_name else get_class()

	_view_ignore = []
	_model_ignore = []

	# register
	_view.register_component(name, self)

	# connect to changes
	view.view_changed.connect(handle_view_change) # this is filtered in LevelView
	view.model_changed.connect(handle_model_change) # this is filtered in LevelView

var _view_ignore: Array

func add_view_ignore(ignore_list: Array):
	for ignore in ignore_list:
		if not _view_ignore.has(ignore):
			_view_ignore.append(ignore)

func del_view_ignore(ignore_list: Array):
	for ignore in ignore_list:
		if _view_ignore.has(ignore):
			_view_ignore.erase(ignore)

func handle_view_change(change):
	if change.type in _view_ignore:
		#print_debug("Ignoring view change.type: ", change.type)
		return true
	return false

var _model_ignore: Array

func add_model_ignore(ignore_list: Array):
	for ignore in ignore_list:
		if not _model_ignore.has(ignore):
			_model_ignore.append(ignore)

func handle_model_change(change: Dictionary):
	if change.type in _model_ignore:
		print_debug("Ignoring model change.type: ", change.type)
		return true
	return false
