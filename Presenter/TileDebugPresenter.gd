class_name TileDebugPresenter extends Node2D

var _parent
var _level_controller: LevelController
var _labels
var _containers
var _menu
var _selected_entry
var _entries

func _init(parent):
	name = "TileDebugPresenter"
	_parent = parent
	_labels = {}
	_containers = {}
	_menu = null
	_selected_entry = ''
	_entries = [
		'coords', 'worm', 'plants', 'smog', 'radiation', 'mycelium-health',
		'resource_amount', 'resource_type', 'discovered', 'water_level', 'water_in_tile',
		'carbon_in_tile', 'minerals_in_tile', 'energy_in_tile',
		]
	_level_controller = LevelController.get_level_controller()
	_level_controller.model_changed.connect(_model_changed)
	visible = false
	z_as_relative = false
	z_index = 200

func _ready():
	_menu = Loader.get_loader().return_scene('tile_debug_menu').instantiate()
	add_child(_menu)
	_menu.visible = visible
	set_process(visible)
	# Propagate menu with what we want
	var hbox = _menu.get_node("Control/PanelContainer/VBoxContainer")
	# set in _init
	for entry in _entries:
		var b: Button = Button.new()
		b.text = entry
		b.pressed.connect(button_pressed.bind(entry))
		hbox.add_child(b)

func button_pressed(entry_key):
	_selected_entry = entry_key
	#print("DebugMenu: entry: %s pressed" % entry_key)

func _process(delta):
	match _selected_entry:
		'worm', 'plants':
			for coords in _labels.keys():
				_labels[coords].text = "%0.2f" %_level_controller.get_tile_at(coords).get_chance(_selected_entry)
		'smog':
			for coords in _labels.keys():
				_labels[coords].text = "%d" % _level_controller.get_tile_at(coords).get_smog()
		'radiation':
			for coords in _labels.keys():
				_labels[coords].text = "%d" % _level_controller.get_tile_at(coords).get_radiation()
		'mycelium-health':
			for coords in _labels.keys():
				#var call = {null: 0, }
				var myc =  _level_controller.get_tile_at(coords).get_mycelium()
				var val
				if myc != null:
					val = "%d" % myc.get_health()
				else:
					val = ';:;'
				_labels[coords].text = val
		'resource_amount', 'resource_type':
			for coords in _labels.keys():
				var object = _level_controller.get_tile_at(coords).get_resource()
				var val
				if object != null:
					if _selected_entry == 'resource_type':
						val = "%s" % ResourceObject.get_resource_type_string(object.get_resource_type())
					if _selected_entry == 'resource_amount':
						val = "%d" % object.get_resource_amount()
				else:
					val = '^.^'
				_labels[coords].text = val
		'discovered':
			for coords in _labels.keys():
				var discovered = _level_controller.get_tile_at(coords).get_discovered()
				_labels[coords].text = str(discovered)
				_labels[coords].modulate = discovered_c[discovered]
		'water_in_tile':
			for coords in _labels.keys():
				var water = _level_controller.get_tile_at(coords).get_tally(ResourceObject.ResourceType.Water)
				_labels[coords].text = "%0.2f" % water
		'carbon_in_tile':
			for coords in _labels.keys():
				var value = _level_controller.get_tile_at(coords).get_tally(ResourceObject.ResourceType.Carbon)
				_labels[coords].text = "%0.2f" % value
		'minerals_in_tile':
			for coords in _labels.keys():
				var value = _level_controller.get_tile_at(coords).get_tally(ResourceObject.ResourceType.Minerals)
				_labels[coords].text = "%0.2f" % value
		'energy_in_tile':
			for coords in _labels.keys():
				var value = _level_controller.get_tile_at(coords).get_tally(ResourceObject.ResourceType.Energy)
				_labels[coords].text = "%0.2f" % value
		'water_level':
			for coords in _labels.keys():
				var water_level = _level_controller.get_water_level(coords)
				_labels[coords].text = "%0.2f" % water_level
		_:
			for coords in _labels.keys():
				_labels[coords].text = "[%d, %d]" % [coords.x, coords.y]

var discovered_c: Dictionary = {
	true: Color.WEB_GREEN,
	false: Color.FIREBRICK,
}
func _model_changed(change):
	# New Tile
	if change.type == 'TileObject' and change.prev == null:
		#print("New tile at %s " % change.coords)
		# change.curr is a tile.

		# add Label at position
		# or add scene that have multiple text fields'n'stuff
		var ctrl: Control = Control.new()
		ctrl.name = "Debug_Ctrl_%d_%d" % [change.coords.x, change.coords.y]
		ctrl.size = Vector2(256, 126)
		ctrl.set_anchors_preset(Control.PRESET_CENTER)
		ctrl.position = _parent.to_position(change.coords) - Vector2(128, 64)
		ctrl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(ctrl)
		_containers[change.coords] = ctrl

		var label: Label = Label.new()
		label.add_theme_color_override("font_outline_color", Color.BLACK)
		label.add_theme_constant_override("outline_size", 1)
		label.text = "[%d, %d]" % [change.coords.x, change.coords.y]
		label.set_anchors_preset(Control.PRESET_FULL_RECT, false)
		#label.position = _parent.to_position(change.coords)
		#label.anchors_preset = Control.PRESET_FULL_RECT
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		# add black outline to white font.
		ctrl.add_child(label)
		_labels[change.coords] = label

# Select what is being displayed
# Menu, button -> enum, enum -> function to get data, update .text

# Menu, add button, based on data, dict
# Menu list_entries: coords, each chance key.
# Menu options: update on _process [on/off - tickbox]

# KEY to show menu & labels
func _unhandled_key_input(event):
	if event.is_action_pressed("toggle_debug"):
		visible = !visible
		_menu.visible = visible
		# when not visible do not run the process
		set_process(visible)
