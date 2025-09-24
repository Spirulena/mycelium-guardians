extends Panel

@export var pause_icon: Texture2D
@export var unpause_icon: Texture2D

@onready var decomposition_progress: ProgressBar = %decomposing_progress
@onready var pause_decomposition = %PauseDecomposition


func _update_pause_icon():
	if false:
		pause_decomposition.icon = unpause_icon
	else:
		pause_decomposition.icon = pause_icon
