extends Node
class_name MouseController

var prev_action: String
var curr_action: String

var current_building_name: String


var _state_handlers: Dictionary
var _gui_controller: GUIController
var _is_temp_action: bool

func _init(gui_controller: GUIController):
	_gui_controller = gui_controller

	_gui_controller.building_selected_for_growth.connect(func(building_id):
		_state_handlers[GUIController.Actions.GrowStructure].set_building_id(building_id)
		current_building_name = BuildingObject.names[building_id]
	)

	_state_handlers = {}
	_is_temp_action = false
	ActionSelect.new(self)
	ActionPrune.new(self)
	ActionExplore.new(self)
	ActionHealMycelium.new(self)
	ActionReleaseAcid.new(self)
	ActionGrowStructure.new(self)
	ActionMaximize.new(self)
	ActionThicken.new(self)

func _ready():
	_gui_controller.action_changed.connect(action_changed)

func view_changed(change):
	_gui_controller.view_changed.emit(change)

func action_changed(prev: String, curr: String): # GUIController.Actions
	prev_action = prev
	curr_action = curr

	_state_handlers[curr].reset()

func swap_action(action: String, coords: Vector2i, next_coords = null):
	_is_temp_action = true
	action_changed(curr_action, action)
	if next_coords != null:
		_state_handlers[action].handle_press(coords, next_coords)
	else:
		_state_handlers[action].handle_press(coords)

func register_action_handler(action, handler):
	_state_handlers[action] = handler

func set_selected(object):
	# TODO: can capture which building was selected if any
	# then can show export menu
	_gui_controller.set_selected(object)

# TODO: need to capture that and expose, so soil_details can read
func set_highlight(coords, highlight):
	# TODO: shall this use different proxy function ?
	view_changed({
			'type': 'set_highlight',
			'prev': null, # TODO: use this
			'curr': true, # TODO: use this
			'highlight': highlight, # this dictates RED / GREEN
			'size': Vector2i(1, 1),
			'coords': coords,
		})

var _previous_coords: Vector2i

func handle_event(event: InputEvent):
	# PRESS #
	if event.is_action_pressed("cancel"):
		set_selected(null)
		if _state_handlers.has(curr_action):
			_state_handlers[curr_action].reset()
		return
	if event.is_action_pressed("game_ui_esc"):
		set_selected(null)
		if _state_handlers.has(curr_action):
			_state_handlers[curr_action].reset()
		return

	var coords = _gui_controller.get_local_mouse_position()

	if not _state_handlers.has(curr_action):
		return

	# PRESS #
	if event.is_action_pressed("mouse_accept") and not event.is_action_pressed("alt_drag"):
		_state_handlers[curr_action].handle_press(coords)

	# MOVE #
	if event is InputEventMouseMotion and coords != _previous_coords:
		_state_handlers[curr_action].handle_move(coords)
		_previous_coords = coords

	# RELEASE #
	if event.is_action_released("mouse_accept"):
		_state_handlers[curr_action].handle_release(coords)
		if _is_temp_action:
			_is_temp_action = false
			action_changed(curr_action, prev_action)

	# When placing structure accept Q, E to change radius
	if event.is_action_pressed("increase_radius") and curr_action == GUIController.Actions.GrowStructure:
		# check if structure is selected as well, if placing
		#print_debug("increase radius key pressed")
		_state_handlers[curr_action].change_radius(+1)
	elif event.is_action_pressed("decrease_radius") and curr_action == GUIController.Actions.GrowStructure:
		#print_debug("decrease radius key pressed")
		_state_handlers[curr_action].change_radius(-1)
