class_name HintController extends Node

var _view: LevelView
var _lc: LevelController
var _gui_controller: GUIController
var expanded_mycelium: bool
var ruin_discovered: bool
var actions_done: Dictionary
var timer: Timer

func _init(parent): # Can pass all from component
	_view = parent
	_gui_controller = _view.game_ui_controller
	_lc = LevelController.get_level_controller()
	name = "HintController"

	# track did player did
	expanded_mycelium = false
	ruin_discovered = false
	actions_done = {
		"expanded_mycelium": false,
	}

# Connect to necessary signals in your game
func _ready():
	#_lc.model_changed.connect(_on_model_changed)

	# TODO: use component thingy for view
	_gui_controller.view_changed.connect(_on_view_changed)

	# add timer, 5 sec no mycelium expansion, show popup
	# TODO: more like have dictionary of timers
	timer = Timer.new()
	timer.wait_time = 5.0  # Set the timer to tick every second
	timer.autostart = false
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	timer.start()

# can just use
var show: Dictionary = {
	"tutorial_show_overlays": false,
	"tutorial_expand_mycelium": false,
	"tutorial_look_for_ruins": false,
}

func _on_timer_timeout():
	if _lc.level_data.hints.is_empty():
		return
	if _lc.level_data.hints["tutorial_expand_mycelium"].show_again:
		display_hint("tutorial_expand_mycelium")
		timer.stop()
		timer.wait_time = 20.0
		timer.start()
		return
	elif expanded_mycelium and _lc.level_data.hints["tutorial_show_overlays"].show_again:
		display_hint("tutorial_show_overlays")
		timer.stop()
		timer.wait_time = 55.0
		timer.start()
		return
	elif not ruin_discovered and _lc.level_data.hints["tutorial_look_for_ruins"].show_again:
	# off timer at some point
		display_hint("tutorial_look_for_ruins")
		timer.stop()
		timer.wait_time = 90.0
		timer.start()
		return
	elif _lc.level_data.hints["tutorial_enzymes"].show_again:
	# off timer at some point
		display_hint("tutorial_enzymes")
		timer.stop()
		timer.wait_time = 90.0
		timer.start()
		return

func _on_model_changed(change):
	pass

#func on_do_not_show_again_toggled(hint_key: String, is_toggled: bool):
	#if hint_key in hints:
		#hints[hint_key].show_again = !is_toggled
		#save_user_preferences()

# TODO:
# add hints for Level09_demo
# this is rather goals, but lets use hints for goals for now.
# Then think how to have hints / goal per level

# 1. Build Radiation Absorber
# 2. Build Smog Absorber
# 3. Build Exchange Center
# 4. Grow Storage Collectors to gather resources.

func _on_view_changed(change):
	# pass the hint, do not show again, key
	# or match change.type:
	if change.type == 'hint' and change.prop == 'show_again':
		var hint_key = change.hint_key
		var show_again = change.curr
		if hint_key in _lc.level_data.hints:
			_lc.level_data.hints[hint_key].show_again = show_again
			_lc.save_user_preferences()
		# hint_key, curr: show_again, prev: prev_show_again
		# 'show_again' change

	elif (change.type == GUIController.Actions.Explore):
			# or maybe when canceled or placed
			if change.state == 'started':
				expanded_mycelium = true
				#display_hint("tutorial_water_overlay_auto")
		# Add other cases as needed
	elif (change.type is String and
			change.type == 'Overlay' and  change.overlay_type == Overlay.OverlayType.Smog and change.curr == true):
				pass
				#display_hint("hint_smog_overlay")
	elif (change.type is String and
			change.type == 'Overlay' and  change.overlay_type == Overlay.OverlayType.Radiation and change.curr == true):
				pass
				#display_hint("hint_radiation_overlay")
	elif (change.type is String and
			change.type == 'Overlay' and  change.overlay_type == Overlay.OverlayType.Water and change.curr == true):
				display_hint("hint_water_overlay")
	# If not reached ruins yet. show tutorial to look for ruins to decompose
	elif change.type == 'ConnectionToBase':
		if change.object.get_type() == ModelObject.Type.Ruin and change.prev == false and change.curr == true:
			ruin_discovered = true
	elif change.type == 'StructureDetailsUI' and change.curr != null:
		display_hint("hint_structure_window_cancel")
	elif (change.type  == GUIController.Actions.GrowStructure):
		if  change.state == 'lack_resources':
			pass # TODO: prune structures to recover some resources
			print_debug("Lack resources, add hint about prune structures")

		#var change: Dictionary = {
		#'type': 'StructureDetailsUI',
		#'coords': structure.get_coords(),
		#'curr': structure,
		#'prev': null,
	# capture if carbon is getting below, or
	# emit change when carbin is in deficit, then hint-> look for ruins for carbon, or trade with plants
	#


func display_hint(hint_key: String):
	if not _lc.level_data.hints.has(hint_key):
		print_debug("No hint with key: ", hint_key)
		return
	if _lc.level_data.hints[hint_key].show_again:
		if 'tutorial_' in hint_key:
			# check if tutorial was, is enabled from this_game_settings.tutorial: bool
			_lc.level_data.hints[hint_key].show_again = false
			_lc.save_user_preferences() # not until we have a save game
			# or have to reset on new_game
		# Code to display the popup with the hint
		open_popup(_lc.level_data.hints[hint_key].text, hint_key)


func open_popup(hint_text: String, hint_key: String):
	# if hints[hint_key].has('media')
	# Show the popup with hint_text
	#print_debug("Pause_game: ", _lc.level_data.hints[hint_key].pause_game)
	#get_tree().paused = _lc.level_data.hints[hint_key].pause_game  # Pause the game
	## Ensure you resume the game when the popup is closed
	print_debug(hint_text, hint_key)

	# Signal to gui or just call function
	var change = {
		'type': 'hint',
		'prop': 'open_popup',
		'hint_key': hint_key, # or just pass hint key, let the gui pull the rest ?
		'hint_text': hint_text,
		'show_again': _lc.level_data.hints[hint_key].show_again,
		'pause_game': _lc.level_data.hints[hint_key].pause_game,
	}
	_gui_controller.view_changed.emit(change)
