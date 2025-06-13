class_name BuildMenu extends Panel

@onready var main_category_tab_container: TabContainer = %BuildingCategories

# Dictionary to hold GridContainers for each category
var category_containers: Dictionary = {}
@export var parent: GUIController
var _lc: LevelController

@export_category("Hover genetics")
@export var genetics_panel: Panel
@export var genetics_label: Label

func _ready():
	genetics_panel.hide()

	_lc = LevelController.get_level_controller() # TODO: set from view
	visible = false
	register()

	# Create GridContainers for each category and add them to the TabContainer
	for category in _lc.get_buildable():
		var center: CenterContainer = CenterContainer.new()
		center.name = "%s".capitalize() % BuildingObject.get_category_string(category) # Set the name of the GridContainer to the category's name

		var margin_container: MarginContainer = MarginContainer.new()
		margin_container.set_anchors_preset(LayoutPreset.PRESET_FULL_RECT)
		margin_container.add_theme_constant_override("margin_top", 20)
		margin_container.add_theme_constant_override("margin_left", 20)
		margin_container.add_theme_constant_override("margin_right", 20)
		margin_container.add_theme_constant_override("margin_bottom", 20)
		margin_container.name = "%s".capitalize() % BuildingObject.get_category_string(category) # Set the name of the GridContainer to the category's name

		var grid_container = GridContainer.new()
		grid_container.columns = 4

		margin_container.add_child(grid_container)  # Add GridContainer to MarginContainer
		center.add_child(margin_container)
		main_category_tab_container.add_child(center)
		#main_category_tab_container.add_child(margin_container)

		category_containers[category] = grid_container

	# Populate with buildings and add buttons
	init_building_buttons()

func register():
	parent.register_global_build_menu(self)

func on_hide_global_build_ui():
	visible = false
	#for button in building_id_to_instance.values():
		#button.unhighlight()
	#get_tree().create_timer(0.2).timeout.connect(reenable_move_keys, CONNECT_ONE_SHOT)

func on_show_global_build_ui():
	visible = true
	#Events.change_move_with_keys_state.emit(false)

var data = {}
var shortcuts_strings = {
	0: "Q",
	1: "W",
	2: "E",
	3: "R",
}
var building_id_to_instance = {}
func init_building_buttons():
	for category in  _lc.get_buildable():
		data[category] = {}
		var building_i = 0
		for building in  _lc.get_buildable()[category]:
			var button: StructurePreviewButton  = Loader.get_loader().return_scene("select_structure_button_preview").instantiate()
			# for keybindings
			data[category][building_i] = building
			building_id_to_instance[building] = button
			button.text = BuildingObject.names[building]
			# TODO: set minature
			button.id = building
			button.resource_out_id = BuildingObject.resource_output[building]

			button.hover_entered.connect(_on_building_hover)
			button.hover_exited.connect(_on_building_hover_exit)

			var costs = _return_costs(building)
			var costs_string: String = _costs_to_string(costs)

			button.tooltip_text = "%s\nCost: %s" % [BuildingObject.tool_tips[building], costs_string]

			button.pressed.connect(func():
				# TODO: How to remove this signal here and pass building id
				parent.building_selected_for_growth.emit(building)
				on_hide_global_build_ui()
			)

			# Add the button to the correct category GridContainer
			category_containers[category].add_child(button)
			#button.set_shortcut_key(shortcuts_strings[building_i])
			building_i += 1

func set_genetics_label():
	# Add genetics number
	var mutation:String = ""
	if Global.gene_base_generation_origin > 0:
		mutation = "\n(Origin: Generation %d" % Global.gene_base_generation_origin
	if Global.gene_base_mutation_id_origin:
		mutation += " Mutation %s)" % Global.gene_base_mutation_id_origin
	var text: String = "Generation #%d%s" % [Global.gene_base_generation, mutation]
	text = text + "\n" + "Decay                | (%0.2fs)" % [Global.gene_base_decay_time]
	var smog_line: =   "Smog change  | (%0.3f/s)" % [Global.gene_base_smog_change]
	var growth_line: = "Growth speed | (%d%%)" % [int(Global.gene_base_growth_factor*100)]
	text = "%s\n%s\n%s" % [text, smog_line, growth_line]
	# Then use RTFLabel

	genetics_label.text = "%s" % text

func _on_building_hover(id):
	if id == BuildingObject.StructureType.Absorber_Smog:
		set_genetics_label()
		genetics_panel.show()

func _on_building_hover_exit(id):
	if id == BuildingObject.StructureType.Absorber_Smog:
		genetics_panel.hide()

func _return_costs(building_type: int):
	return BuildingObject.growth_cost[building_type]

func _costs_to_string(costs: Dictionary):
	var component: Array = []
	for type in ResourceObject.ResourceType.values(): #TODO use proxy function so we can exclude none
		if costs[type] > 0:
			component.append("%s: %d" % [ResourceObject.ResourceType.keys()[type], costs[type]])
	return "; ".join(component)

func _handle_structure(index: int):
	for button in building_id_to_instance.values():
		button.unhighlight()
	if data[main_category_tab_container.current_tab].has(index):
		var building = data[main_category_tab_container.current_tab][index]
		parent.building_selected_for_growth.emit(building)
		building_id_to_instance[building].highlight()

func _handle_category_change(index: int):
	main_category_tab_container.current_tab = index

func reenable_move_keys():
	pass
	# TODO: use something else then signal
	#Events.change_move_with_keys_state.emit(true)
