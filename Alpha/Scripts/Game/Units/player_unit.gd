extends Node

@onready var selection_visual = $"../UnitSelectionHighlight"

func toggle_selection_visual (toggle : bool):
	selection_visual.visable = toggle
