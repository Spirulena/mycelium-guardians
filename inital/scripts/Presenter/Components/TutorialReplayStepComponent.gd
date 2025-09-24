class_name TutorialReplayStepComponent extends ViewComponent

var _replay_call: Callable
var _exit_call: Callable

func setup(replay_call: Callable, exit_call: Callable):
	_replay_call = replay_call
	_exit_call = exit_call
	# show replay button
	# if replay call is empty, hide replay button
	# emit some change to do that

func _ready() -> void:
	pass

func handle_view_change(change):
	if super.handle_view_change(change):
		return

	if change.type == 'tutorial' and change.prop == 'button_pressed' and change.curr == 'replay_instruction' and change.prev == null:
		_replay_call.call()
	if change.type == 'tutorial' and change.prop == 'button_pressed' and change.curr == 'exit_instruction' and change.prev == null:
		_exit_call.call()

func hide_replay_window():
	_gui.view_changed.emit({
		'type': 'tutorial',
		'prop': 'hide_window',
		'curr': 'replay_window',
		'prev': null,
	})

func show_replay_window():
	_gui.view_changed.emit({
		'type': 'tutorial',
		'prop': 'show_window',
		'curr': 'replay_window',
		'prev': null,
	})
