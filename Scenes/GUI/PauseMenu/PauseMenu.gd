extends Control

@export var parent: Main

func _view_changed(change):
	# NOTE: or use signal ?
	parent.main_view_changed.emit(change)
