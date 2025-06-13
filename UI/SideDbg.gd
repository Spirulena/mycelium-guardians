extends Control

@export var parent: Node
@onready var vbox: VBoxContainer
@onready var labels: Array[Label]
var _lc: LevelController
var _current_tile: TileObject

func _ready():
	_lc = LevelController.get_level_controller()
	vbox = VBoxContainer.new()
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(vbox)
	# prepop labels
	labels.resize(15)
	for label_i in range(labels.size()):
		labels[label_i] = Label.new()
		vbox.add_child(labels[label_i])
		labels[label_i].mouse_filter = Control.MOUSE_FILTER_IGNORE
		#labels[label_i].add_theme_font_size_override("font_size", 18)
		labels[label_i].add_theme_constant_override("outline_size", 1)
		labels[label_i].add_theme_color_override("font_outline_color", Color.BLACK)

# TODO: prepopulate with few labels, reuse them

func set_highlight(change):
	if not is_instance_valid(_lc):
		return
	var tile:TileObject = _lc.get_tile_at(change.coords)
	if tile == null:
		return
	update_tile_details(tile)
	# Now also update when tile changes
	if _current_tile != tile:
		# try disconnect
		if _current_tile != null and _current_tile.tile_changed.is_connected(_on_tile_changed):
			_current_tile.tile_changed.disconnect(_on_tile_changed)
		_current_tile = tile
		tile.tile_changed.connect(_on_tile_changed)

func _on_tile_changed(change):
	update_tile_details(change.tile)

func update_tile_details(tile:TileObject):
	for child in vbox.get_children():
		child.hide()
	var coords = tile.get_coords()
	var i = 0
	# 0: show coords,
	labels[i].text = "[%s, %s]" % [coords.x, coords.y]
	labels[i].show(); i += 1
	if not tile.get_discovered():
		return
	# 1: smog,
	labels[i].text = "Smog: %d" % [tile.get_smog()]
	labels[i].show(); i += 1
	# 2: radiation,
	labels[i].text = "Radiation: %d" % [tile.get_radiation()]
	labels[i].show(); i += 1
	# 3: water level,
	# TODO: only on visible tile
	if _lc.get_water_level(coords) > 0.33:
		labels[i].text = "Water: %0.2f" % [_lc.get_water_level(coords)]
		labels[i].show(); i += 1

	var objects:Array[ModelObject] = tile.get_objects()
	if objects.size() > 0:

		# Add label in Hbox for each object, print its name
		for object in objects:
			if object == null:
				continue
			labels[i].text = object.get_type()
			labels[i].show(); i += 1
			if object.get_type() == ModelObject.Type.Mycelium:
				# show distance to base
				labels[i].text = "Distance to base: %d" % [_lc.distance_to_base(coords)]
				labels[i].show(); i += 1
			elif object.get_type() == ModelObject.Type.Building:
				var structure = tile.get_structure() as BuildingObject
				if structure != null:
					var building_name = BuildingObject.names.get(structure.get_building_type(), "??")
					var category = BuildingObject.get_building_category_string(structure.get_building_type())
					labels[i].text = "%s %s" % [building_name, category]
					labels[i].show(); i += 1
