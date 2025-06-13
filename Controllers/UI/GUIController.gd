extends CanvasLayer
class_name GUIController

static var Actions: Dictionary = {
	"Select": "select",
	"Explore": "explore",
	"Prune": "prune",
	"GrowStructure": "grow_structure",
	"RemoveMaximize": "remove_maximize",
	"Maximize": "maximize",
	"Thicken": "thicken",
	"ReleaseAcid": "release_acid",
	"HealMycelium": "heal_mycelium",
}

@export_category("bottom menu")
@export var bottom_normal_position: Vector2
@export var bottom_open_position: Vector2
@export var bottom_menu_texture: TextureRect
@export_category("network menu")
@export var network_button: TextureButton
@export_category("Canvas Layers")
@export var map_gui: CanvasLayer
@export_category("Actions")
@export var default_action: String = "select"
#@export var tile_details_panel: Node
#@export var structures_details_panel: Node

@onready var show_hide_hints: Button = %ShowHideHints

@onready var resources_panel = %ResourcesPanel
@onready var overlays_ui_menu = %OverlaysUIMenu

@onready var side_dbg: Control = %SideDbg

var visible_elements : Array = []
var currently_selected_colony = 0
var dragging_screen : bool = false
var global_building_menu_opened: bool = false

@onready var _current_action_mode: String
@onready var _current_selection
@onready var global_build_menu
@onready var windows_canvas = $WindowsCanvas
@onready var hint_container: VBoxContainer = $Screens/Hint/VBoxContainer
@onready var template_single_hint: SingleHintWindowPresenter = $Screens/Hint/VBoxContainer/TemplateSingleHint

@onready var structure_smog: PanelContainer = $Screens/StructureDetails/Smog
@onready var export_ui: Control = $Screens/StructureDetails/ExportUI
@onready var ruins_ui: PanelContainer = $Screens/StructureDetails/Ruins

@onready var structure_details = $Screens/StructureDetails

@onready var overlay_hint: Control = %OverlayHint
@onready var overlay_hint_label: Label = %overlay_hint_label

var _mouse_controller: MouseController
var _iso_grid
@onready var _screens # keep, world_view, pause_menu, base_screen here, animations

signal view_changed(change: Dictionary)
signal action_changed(prev: String, curr: String)
signal building_selected_for_growth(building_id)

var _history_displayed
var _lc: LevelController
var _hint_windows: Dictionary
var _handle_events_enabled: bool

func set_handle_events(state: bool):
	_handle_events_enabled = state

func _init():
	ignore_view_change_type = []
	_handle_events_enabled = true
	_lc = LevelController.get_level_controller()
	_history_displayed = {}
	_hint_windows = {}
	_screens = {
		'GUI': {
			'reference': null,
			'default_visiblity': true,
		},
		'MapGUI':{
			'reference': null,
			'default_visiblity': true,
		},
		'WindowsCanvas':{
			'reference': null,
			'default_visiblity': true,
		},
		'Screens': {
			'reference': null,
			'default_visiblity': true,
		},
		'PopUp': {
			'reference': null,
			'default_visiblity': false,
		},
		'ColonyBase':{
			'reference': null,
			'default_visiblity': false,
		},
		'WorldMap': {
			'reference': null,
			'default_visiblity': false,
		},
	}

func default_visibility():
	overlays_ui_menu.show()
	$MapGUI.show()
	$Screens.show()

@onready var elements:Dictionary = {
	'ZoomUI': %ZoomGui,
	'ResourcesPanel': resources_panel,
	'BottomMenu': [$MapGUI/BottomMenuBackground, $MapGUI/BottomButtons]
}

func show_element(element: String):
	match element:
		'ZoomUI':
			var tween: Tween = elements['ZoomUI'].create_tween()
			tween.tween_property(elements['ZoomUI'], "modulate:a", 1.0, 0.5).from(0.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
			elements['ZoomUI'].show()
		'BottomMenu':
			for el in elements['BottomMenu']:
				var tween: Tween = el.create_tween()
				tween.tween_property(el, "modulate:a", 1.0, 0.5).from(0.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
				el.show()
		'ResourcesPanel':
			var tween: Tween = elements['ResourcesPanel'].create_tween()
			tween.tween_property(elements['ResourcesPanel'], "modulate:a", 1.0, 0.5).from(0.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
			elements['ResourcesPanel'].show()

func hide_element(element: String):
	match element:
		'ZoomUI':
			%ZoomGui.hide()
		'BottomMenu':
			# put into one
			$MapGUI/BottomMenuBackground.hide()
			$MapGUI/BottomButtons.hide()
		'SideDebug':
			%SideDebug.hide()
		'ResourcesPanel':
			# move the label to the panel
			resources_panel.hide()
			%ResourcesLabel.hide()
		'Overlay':
			overlays_ui_menu.hide()
		'MapGUI':
			$MapGUI.hide()
		'Screens':# TODO: all screens but Pause, Help, WorldMap, maybe move some screens to MapGUI,
			# Like structures, Hints, EnzymesPanelUI,
			$Screens.hide()
		_:
			print_debug("No match: ", element)


# WHY This data is here ?
# Should be defined in Building Resource file,

# "Water Overlay: Blue tiles show underground water concentrations, with darker shades indicating richer water sources. Mycelium can extract water from these areas to support growth and expansion"
var overlay_structures_hints_text: Dictionary = {
	BuildingObject.StructureType.Missing: "",
	BuildingObject.StructureType.Storage_Water: "Water Storage Overlay: Areas in blue show water in the soil, collectable by growing a Water Storage Collector",
	BuildingObject.StructureType.Storage_Energy:  "Energy Overlay: Color intensity indicates energy levels, from low (light) to high (dark). Utilize an Energy Storage Collector to collect",
	BuildingObject.StructureType.Storage_Minerals: "Minerals Overlay: Tiles indicate mineral levels, from scarce (lighter) to rich (darker). Collect with a Minerals Storage Collector",
	BuildingObject.StructureType.Storage_Carbon: "Carbon Overlay: Shades from light to dark represent carbon availability in the soil. Harvest with a Carbon Storage Collector",
	BuildingObject.StructureType.Absorber_Radiation: "Radiation Overlay: Place the Radiation Absorber in zones with darker coloration to convert radiation into energy. Excess minerals can be collected with an Energy Storage Collector",
	BuildingObject.StructureType.Absorber_Smog: "Smog Overlay: Install the Smog Absorber in denser smog areas to transform pollution into minerals. Excess minerals can be collected with a Minerals Storage Collector",
	BuildingObject.StructureType.Export_Center: "Export Center: Ideal placement is in clear areas devoid of smog to enhance photosynthesis and facilitate plant growth. Excess carbon can be collected with a Carbon Storage Collector within its radius",
}

var overlay_hints_text: Dictionary = {
	Overlay.OverlayType.WaterStorage: "Water Storage Overlay: Areas in blue show water in the soil, collectable by growing a Water Storage Collector",
	Overlay.OverlayType.EnergyStorage:  "Energy Overlay: Color intensity indicates energy levels, from low (light) to high (dark). Utilize an Energy Storage Collector to collect",
	Overlay.OverlayType.MineralsStorage: "Minerals Overlay: Tiles indicate mineral levels, from scarce (lighter) to rich (darker). Collect with a Minerals Storage Collector",
	Overlay.OverlayType.CarbonStorage: "Carbon Overlay: Shades from light to dark represent carbon availability in the soil. Harvest with a Carbon Storage Collector",
	Overlay.OverlayType.Radiation: "Radiation Overlay: Place the Radiation Absorber in zones with darker coloration to convert radiation into energy. Excess minerals can be collected with an Energy Storage Collector",
	Overlay.OverlayType.Smog: "Smog Overlay: Install the Smog Absorber in denser smog areas to transform pollution into minerals. Excess minerals can be collected with a Minerals Storage Collector",
	Overlay.OverlayType.Water: "Water Overlay: Blue tiles show underground water concentrations. Mycelium extracts water from these areas to support growth and expansion. Deploy a Water Storage Collector here to efficiently harvest excess water",
}
# Add export_overlay ? shows green where there is no smog and no radiation ?

func update_overlay_structure_text(building_id: BuildingObject.StructureType):
	var text = overlay_structures_hints_text.get(building_id, '')
	overlay_hint_label.text = text

func update_overlay_text(overlay_type: Overlay.OverlayType):
	var text = overlay_hints_text.get(overlay_type, '')
	overlay_hint_label.text = text

var _show_overlay_hints: bool = true
func set_show_overlay_hints(state: bool) -> void:
	_show_overlay_hints = state

func overlay_hint_show():
	if not _show_overlay_hints:
		return
	overlay_hint.show()
	var tween_a: Tween = overlay_hint.create_tween()
	tween_a.tween_property(overlay_hint, "modulate:a", 1.0, 0.25).from(0.0).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)

func overlay_hint_tween_hide():
	var tween_a: Tween = overlay_hint.create_tween()
	tween_a.tween_property(overlay_hint, "modulate:a", 0.0, 0.2).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)
	#tween_a.tween_callback(overlay_hint.hide)

func _init_show_hide_hints_button():
	show_hide_hints.pressed.connect(_on_show_hide_hints)
	update_show_hide_hints_button()
	show_hide_hints.visible = false # start with not visible, until we have first tip

# Tutorial Replay
# Maybe move to component ?
# TODO: make component system for GUI
@onready var tutorial_replay: Control = $Screens/TutorialReplay
@onready var replay_v_instruction: TextureButton = %ReplayVInstruction
@onready var enter_v_action: TextureButton = %EnterVAction


func _ready():
	Global.main.main_view_changed.connect(_on_main_view_changed)
	# NOTE: Tutorial replay component ready
	tutorial_replay.hide()
	replay_v_instruction.pressed.connect(func():
		print_debug("replay")
		view_changed.emit({
			'type': 'tutorial',
			'prop': 'button_pressed',
			'curr': 'replay_instruction',
			'prev': null,
		}))
	enter_v_action.pressed.connect(func():
		print_debug("replay")
		view_changed.emit({
			'type': 'tutorial',
			'prop': 'button_pressed',
			'curr': 'exit_instruction',
			'prev': null,
		}))
	# NOTE: End of Tutorial replay component ready

	$MapGUI/debug_background.hide()
	_init_show_hide_hints_button()

	overlay_hint.hide()
	not_enough.hide()
	%Grow.hide() # keybindings hints for growing structures
	cost.hide() # building costs

	template_single_hint.hide()
	structure_details.hide()
	for child in structure_details.get_children():
		child.hide()
	#structure_radiation.hide()
	#structure_smog.hide()
	#export_ui.hide()
	# Can later on load with Loader, add_child
	_screens['GUI']['reference'] = self
	_screens['MapGUI']['reference'] = $MapGUI
	_screens['WindowsCanvas']['reference'] = $WindowsCanvas
	_screens['Screens']['reference'] = $Screens
	_screens['ColonyBase']['reference'] = $Screens/ColonyBase
	_screens['WorldMap']['reference'] = $Screens/WorldMap

	for screen in _screens.keys():
		if _screens[screen] != null:
			_screens[screen].visible = _screens[screen]['default_visiblity']

	_mouse_controller = MouseController.new(self)
	_mouse_controller.name = "MouseController"
	add_child(_mouse_controller)

	_current_action_mode = default_action
	set_current_action_mode(default_action)
	set_selected(null)

	view_changed.connect(_on_view_changed)
	# increase reduce radius buttons
	reduce_radius_button.pressed.connect(decrease_radius)
	increase_radius_button.pressed.connect(increase_radius)

	## Connect Network button to signal handlers
	network_button.mouse_entered.connect(func(): network_button.scale = Vector2(1.1, 1.1))
	network_button.mouse_exited.connect(func(): network_button.scale = Vector2(1, 1))
	network_button.pressed.connect(on_network_button_pressed)

@export var network_menu: NetworkMenu
func on_network_button_pressed():
	network_menu.visible = ! network_menu.visible
	print_debug("Network menu open request")
	# Spawn or show a window with
	# Place path -> change mode to gesture thing
	# Dig for something
	# Thicken
	# Enzymes ?
	# Open details of tile ?

@onready var reduce_radius_button: Button = %ReduceRadiusButton
@onready var increase_radius_button: Button = %IncreaseRadiusButton

func increase_radius():
	_mouse_controller._state_handlers[GUIController.Actions.GrowStructure].change_radius(+1)

func decrease_radius():
	_mouse_controller._state_handlers[GUIController.Actions.GrowStructure].change_radius(-1)

@onready var cost: PanelContainer = %Cost
@onready var costs_label: Label = %costs_label
func update_cost(building_type, radius):
	var building_name = BuildingObject.get_building_category_string(building_type)
	var building_cost = BuildingObject.get_growth_cost_preview(building_type, radius)
	var building_cost_string = BuildingObject.costs_to_string(building_cost)
	var cost_string_template ="""%s, radius: %d
Cost:
%s"""
	# tween size
	costs_label.text = cost_string_template % [building_name, radius, building_cost_string]

@onready var not_enough: Control = %NotEnough

func _on_main_view_changed(change: Dictionary) -> void:
		# Help Screen
	if change.type == 'LevelGUI':
		map_gui.visible = change.curr
		pass

var ignore_view_change_type: Array


# TODO: Bottom mushroom cap, up when network menu selected
#
func _on_view_changed(change):
	if change.type in ignore_view_change_type:
		#print_debug("Ignoring view change.type == ", change.type)
		return
	# FIX: pause menu from the button does not work, does not go to
	# main_view_changed
	# TODO: show tutorial replay window
	#
	if change.type == 'tutorial' and change.prop == 'show_window' and change.curr == 'replay_window' and change.prev == null:
		tutorial_replay.show()
	if change.type == 'tutorial' and change.prop == 'hide_window' and change.curr == 'replay_window' and change.prev == null:
		tutorial_replay.hide()

	elif (change.type  == GUIController.Actions.Explore):
		if change.state == 'cancelled':
			#if overlay_hint.visible:
				#overlay_hint_tween_hide()
			pass #hide hint water overlay
		elif change.state == 'started':
			pass # show hint about its water overlay, water underground
			#overlay_hint_label.text = "Water Overlay: Blue tiles show underground water concentrations, with darker shades indicating richer water sources. Mycelium can extract water from these areas to support growth and expansion"
			#overlay_hint_show()
		elif change.state == 'moving':
			pass# do nothing
		elif change.state == 'placed':
			#overlay_hint_tween_hide()
			pass # hide
	elif change.type == 'Overlay':
		if change.overlay_type == null and change.curr == null:
			#print_debug("From OverlayViewComponent overlay clear : ", change)
			#print("OverlayH: Hiding")
			overlay_hint_tween_hide()
		elif change.overlay_type != null and change.overlay_type != Overlay.OverlayType.All and change.curr == null:
			#print_debug("overlay set in OverlayViewComponent")
			update_overlay_text(change.overlay_type)
			overlay_hint_show()
			#print("OverlayH: Showing")

		elif change.overlay_type != null and change.overlay_type != Overlay.OverlayType.All and change.curr == true:
			pass
			#print_debug("Overlay_ui_menu send that:", change) # ignore that
		elif (change.overlay_type == Overlay.OverlayType.All and change.curr == false):
			pass
			#print_debug("From overlays_ui_menu: overlay all hide") #ignore
	elif (change.type  == GUIController.Actions.GrowStructure):
		if change.state == 'cancelled':
			pass
			if overlay_hint.visible:
				if change.curr == BuildingObject.StructureType.Export_Center:
					overlay_hint_tween_hide()
					pass
		if change.state == 'selected':
			%Grow.show()
			# Show also costs of building
			#print_debug(BuildingObject.get_growth_cost_preview(change.curr, change.radius))
			cost.show()
			update_cost(change.curr, change.radius)
			# set text
			# TODO: add text for other structures, for all
			if change.curr == BuildingObject.StructureType.Export_Center:
				update_overlay_structure_text(change.curr)
				overlay_hint_show()
			#if BuildingObject.get_building_category(change.curr) == BuildingObject.StructureCategory.Storage:
				#update_overlay_storage_text(change.curr)
				#overlay_hint_show()
			#else:
				#overlay_hint_tween_hide()
		elif change.state == 'change_radius' and change.type == GUIController.Actions.GrowStructure:
			#print_debug(BuildingObject.get_growth_cost_preview(change.type, change.radius))
			if change.building_id == -1:
				return
			update_cost(change.building_id, change.radius)
			if change.curr > change.prev:
				pass # twin up size
				var tween_s: Tween = cost.create_tween()
				tween_s.tween_property(cost, "scale", Vector2(1.3, 1.4), 0.1).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO).set_delay(0.05)
				tween_s.tween_property(cost, "scale", Vector2.ONE, 0.05).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)
			else:
				pass # twin smaller size
				var tween_s: Tween = cost.create_tween()
				tween_s.tween_property(cost, "scale", Vector2(0.6, 0.7), 0.1).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO).set_delay(0.05)
				tween_s.tween_property(cost, "scale", Vector2.ONE, 0.05).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)
			pass # update cost
		elif change.state == 'placed' or change.state == 'cancelled':
			cost.hide()
		elif  change.state == 'lack_resources':
			not_enough.show()
			# TODO: Have this in hint
			var tween_a: Tween = not_enough.create_tween()
			tween_a.tween_property(not_enough, "modulate:a", 1.0, 0.5).from(0.0).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)
			tween_a.tween_property(not_enough, "modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT).set_delay(3)
			tween_a.tween_callback(not_enough.hide)
			var tween_s: Tween = not_enough.create_tween()
			tween_s.tween_property(not_enough, "scale", Vector2(1.3, 1.4), 0.1).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO).set_delay(0.05)
			tween_s.tween_property(not_enough, "scale", Vector2.ONE, 0.05).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)
			print_debug("Not enough resources to grow")

	if (change.type == 'set_highlight'):
		side_dbg.set_highlight(change)

	elif (change.type == 'hint' and change.prop == 'open_popup'):
			pass
			var hint_key = change.hint_key
			var hint_text = change.hint_text
			var show_again = change.show_again
			var pause_game = _lc.level_data.hints[hint_key].pause_game
			get_tree().paused = pause_game # Pause the game
			add_hint(hint_key, hint_text, show_again)
			# open popup window
		#'type': 'hint',
		#'prop': 'open_popup',
		#'hint_key': hint_key, # or just pass hint key, let the gui pull the rest ?
		#'hint_text': hint_text,
		#'show_again': _lc.level_data.hints[hint_key].show_again,
		#'pause_game': _lc.level_data.hints[hint_key].pause_game,

@onready var show_hide_hints_text: Dictionary = {
	true: " < ",
	false: " > ",
}
@onready var show_hide_hints_hint_text: Dictionary = {
	true: "Hide hints",
	false: "Show hints",
}

func _on_show_hide_hints():
	hint_container.visible = !hint_container.visible
	update_show_hide_hints_button()

func update_show_hide_hints_button():
	show_hide_hints.text = show_hide_hints_text[hint_container.visible]
	show_hide_hints.tooltip_text = show_hide_hints_hint_text[hint_container.visible]

func add_hint(hint_key: String, hint_text: String, show_again: bool):
	show_hide_hints.visible = true
	# store window reference ?
	if _hint_windows.has(hint_key):
		return
	var _instance: SingleHintWindowPresenter = Loader.get_loader().return_scene("single_hint_window").instantiate()
	_instance.mouse_filter = Control.MOUSE_FILTER_STOP
	_hint_windows[hint_key] = _instance
	hint_container.add_child(_instance)
	_instance.set_hint_text(hint_text)
	_instance.set_hint_key(hint_key)
	_instance.set_show_again(show_again)
	_instance.ok_pressed.connect(_on_ok_hint_pressed)
	# add popup to hbox, or scrollable window; not scrolable keep limit.
	# set data
	# show the window
	pass

func _on_ok_hint_pressed(hint_key):
	if not _hint_windows.has(hint_key):
		print_debug("no hint with key ", hint_key)
		return
	var _instance: SingleHintWindowPresenter = _hint_windows[hint_key]
	if 'hint_' in hint_key:
		var show_again = _instance._show_again # todo, should pass the data in signal ?
		_lc.level_data.hints[hint_key].show_again = show_again # check if it is changed ?
		_lc.save_user_preferences() # not until we have a save game
	await get_tree().process_frame
	# if _show_again changed, update it
	hint_container.remove_child(_instance)
	_hint_windows.erase(hint_key)
	_instance.queue_free()

# actually care about was show again toggled when hitting ok

func register_global_build_menu(menu):
	global_build_menu = menu

func set_iso_grid(iso_grid):
	_iso_grid = iso_grid

func get_iso_grid():
	return _iso_grid

func get_local_mouse_position():
	return _iso_grid.local_to_map(_iso_grid.get_local_mouse_position())

func local_to_map(local_position: Vector2) -> Vector2i:
	return _iso_grid.local_to_map(local_position)

func set_selected(objects):
	#objects, is either null, or {'coords': coords,'tile': tile,}
	var prev = _current_selection
	var curr = objects
	_current_selection = objects

	# TODO: can capture which building was selected if any
	# then can show export menu

	if curr != null and curr.tile != null:
		var overground = curr.tile.get_overground()
		if overground != null and overground.get_type() == ModelObject.Type.Building:
			overground.set_selected(true)
			# just show building window
			# this will filter which one to show
			handle_structure_window(overground, curr.tile)
		elif overground != null and overground.get_type() == ModelObject.Type.Ruin:
			print_debug("show RUIN UI")
			handle_ruins_window(overground)
	elif curr == null:
		structure_details.hide()
	if prev != null and curr != prev:
		var overground = prev.tile.get_overground()
		if overground != null and overground.get_type() == ModelObject.Type.Building:
			overground.set_selected(false)
				# Then might not need to open tile_details, structures_details
				# show radius of effect ?

	# FIXME: not very modular is it ?
	#tile_details_panel.selection_changed(prev, curr)
	#structures_details_panel.selection_changed(prev, curr)

func handle_ruins_window(ruins: RuinObject):
	for child in structure_details.get_children():
		child.hide()
	structure_details.show()
	# its only used for hints
	var change: Dictionary = {
		'type': 'RuinDetailsUI',
		'coords': ruins.get_coords(),
		'curr': ruins,
		'prev': null,
	}
	view_changed.emit(change) #audio could also react to it. Or just trigger a sound here
	ruins_ui.init(ruins)
	ruins_ui.show()

func handle_structure_window(structure:BuildingObject, tile: TileObject):
	for child in structure_details.get_children():
		child.hide()
	structure_details.show()

	# its only used for hints
	var change: Dictionary = {
		'type': 'StructureDetailsUI',
		'coords': structure.get_coords(),
		'curr': structure,
		'prev': null,
	}
	view_changed.emit(change)

	match structure.get_building_type():
		BuildingObject.StructureType.Absorber_Smog:
			print("OPEN Smog GUI")
			structure_smog.init(structure, tile)
			structure_smog.show()
		BuildingObject.StructureType.Export_Center:
			export_ui.init(structure)
			export_ui.show()
			print("OPEN Export GUI")

func set_current_action_mode(value):
	var prev: String = _current_action_mode
	var curr: String = value
	_current_action_mode = value

	action_changed.emit(prev, curr)

	if prev != GUIController.Actions.HealMycelium and curr == GUIController.Actions.HealMycelium:
		view_changed.emit({
			'prev': null,
			'curr': true,
			'type': 'Overlay',
			'overlay_type': Overlay.OverlayType.MyceliumHealth,
		})
	if prev == GUIController.Actions.HealMycelium and curr != GUIController.Actions.HealMycelium:
		# Hide Overlay
		view_changed.emit({
			'prev': true,
			'curr': false,
			'type': 'Overlay',
			'overlay_type': Overlay.OverlayType.MyceliumHealth,
		})
	if  prev == GUIController.Actions.GrowStructure and curr != GUIController.Actions.GrowStructure:
		%Grow.hide()
		pass # if placing structure, we need to emit cancelled first.
	if prev != GUIController.Actions.GrowStructure and curr == GUIController.Actions.GrowStructure:
		if global_build_menu != null:
			global_build_menu.on_show_global_build_ui()
	if  prev == GUIController.Actions.GrowStructure and curr != GUIController.Actions.GrowStructure:
		if global_build_menu != null:
			global_build_menu.on_hide_global_build_ui()
	if prev == GUIController.Actions.GrowStructure and curr == GUIController.Actions.GrowStructure:
		if global_build_menu != null:
			global_build_menu.on_hide_global_build_ui()
		set_current_action_mode(GUIController.Actions.Select)

func resource_changed(change):
	resources_panel.resource_changed(change)

func resource_limit_changed(change):
	resources_panel.resource_limit_changed(change)

func ruin_touched(ruin, coords):
	# Move that to LevelData, GameData, PresenterData ?
	#can use model change
	#if change.type == 'ConnectionToBase':
		#if change.object.get_type() == ModelObject.Type.Ruin and change.prev == false and change.curr == true:
			#print_debug("Ruin connected")
	return
	if _history_displayed.has(ruin):
		return
	_history_displayed[ruin] = ruin
	var instance = Loader.get_loader().return_scene('ruins_backstory_window').instantiate()
	_screens['WindowsCanvas']['reference'].add_child(instance)
	_screens['PopUp']['reference'] = instance

	# if Pause Menu or other are visible, this should be shown,
	# Also should not lock the buttons in main menu
	# Now have to click continue, then can click in pause menu
	# add To Popup container ?

func show_world_map_pressed():
	_screens['WorldMap']['reference'].show()

func close_world_map_pressed():
	_screens['WorldMap']['reference'].hide()

func hide_colony_base_pressed():
	pass

# NOTE: single point of handling input
func _unhandled_input(event: InputEvent) -> void:
	# TODO: move away input handling from mouse controller
	if _handle_events_enabled:
		_mouse_controller.handle_event(event)

	if event.is_action_pressed("cancel"):
		set_current_action_mode(default_action)
		set_selected(null)
	if event.is_action_pressed("game_ui_esc"):
		#set_selected(null)
		#if _state_handlers.has(curr_action):
			#_state_handlers[curr_action].reset()
		#return

		set_selected(null)
		if _current_action_mode != default_action:
			# FIXME: this does not work well when placing structure.
			set_current_action_mode(default_action)
		else:
			# Dont like it.
			# Set the data, then let the data changes take care of it in the component
			# Like in interceptor
			# Sill how to have an order of how to set the data. Ei. what to set to hidden

# TODO: FIXME:
# When in pause menu, do not show PopUp, or show below.

			if (_screens['PopUp']['reference'] != null and _screens['PopUp']['reference'].visible):
				_screens['PopUp']['reference'].on_confirm_button()
			elif _screens['WorldMap']['reference'].visible:
				_screens['WorldMap']['reference'].hide()
			else:
				#print_debug()
				Global.main.pause_game()

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_in_requested()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_out_requested()
	if event.is_action("zoom_in"):
		zoom_in_requested()
	if event.is_action("zoom_out"):
		zoom_out_requested()

	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE) or \
		event is InputEventMouseMotion and Input.is_action_pressed("alt_drag"):
		view_changed.emit({
			'type': 'MouseDrag',
			'prev': null,
			'curr': event.relative
		})

func zoom_in_requested():
	view_changed.emit({
		'type': 'Zoom',
		'prev': null,
		'curr': 'in'
	})

func zoom_out_requested():
	view_changed.emit({
		'type': 'Zoom',
		'prev': null,
		'curr': 'out'
	})

func zoom_reset_requested():
	view_changed.emit({
		'type': 'Zoom',
		'prev': null,
		'curr': "reset",
	})
