extends PanelContainer

# Ruins UI

@onready var _model: RuinObject

@onready var name_label: Label = %name_label
@onready var coords_label: Label = %coords_label

@onready var last_energy_input: Label = %last_energy_input
@onready var last_enzymes_consumed: Label = %last_enzymes_consumed
@onready var last_water_output: Label = %last_water_output
@onready var last_energy_output: Label = %last_energy_output
@onready var last_minerals_output: Label = %last_minerals_output
@onready var last_carbon_output: Label = %last_carbon_output




@onready var active_button: CheckButton = %active_button

@onready var when_connected: VBoxContainer = %when_connected

@onready var resource_out_labels: Dictionary = {
		ResourceObject.ResourceType.Water: last_water_output,
		ResourceObject.ResourceType.Energy: last_energy_output,
		ResourceObject.ResourceType.Minerals: last_minerals_output,
		ResourceObject.ResourceType.Carbon: last_carbon_output,
		ResourceObject.ResourceType.Acid: null,
		ResourceObject.ResourceType.Enzymes: null,
}

var timer: Timer
@onready var harvesters: Dictionary

func update_resource_out():
	init_harvesters()
	for resource_type in  resource_out_labels.keys():
		if resource_out_labels[resource_type] != null:
			# match with harvester from _model
			if harvesters.get(resource_type) != null:
				var harvester: HarvesterObject = harvesters[resource_type]
				var last = harvester.last_extracted_amount
				var res_string = ResourceObject.get_resource_type_string(resource_type)
				resource_out_labels[resource_type].text = "%s decomposition rate: %0.2f/s" % [res_string, last]
				resource_out_labels[resource_type].visible = true

func init_harvesters():
	for harvester in _model._harvesters:
		var coords = harvester.get_coords()
		var res_type = null
		for resource in _model._resources:
			if resource.get_coords() == coords:
				res_type = resource.get_resource_type()
		if res_type != null:
			harvesters[res_type] = harvester
		else:
			pass

func init(model):
	#if _model != null:
		#_model.state_changed.disconnect(_on_state_changed)
	_model = model
	#_model.state_changed.connect(_on_state_changed)

	update_data()
	#timer.start()

@onready var ruin_db_text: RichTextLabel = %ruin_db_text
func update_story():
	ruin_db_text.text = _model._ruin_text

func update_data():
	update_resource_out()
	name_label.text = _model._ruin_name
	coords_label.text = "[%s, %s]" % [_model.get_coords().x, _model.get_coords().y]
	update_story()
	update_resources()
	update_connected_status()
	when_connected.visible = _model._connected_to_base

	# Update when connected data

	# Update connection to mycelium status
	# Grown over with MYC status.
	# Harvester, extraction rate.
	# What resources are on there
	# Resources extracted, left resource ?

	# Show growing progress bar.
	# Building Status -> String keys, to show in UI
	#growing_status()
	#if _model.get_state() == BuildingObject.BuildingState.Done:
	#update_input_output()
	#set_processing_tiles(_model.processing_coords_amount)
	# TODO: add slider, how many tiles to process
	# value min 0, max processing_coords_amount.size()
	#_init_visibility_on_building_status()
	#active_button.text = active_button_text[_model._production_active]
	#active_button.button_pressed = _model._production_active
	#update_production_efficiency()
	#update_missing_resources()

@onready var connected_to_base_label: Label = %connected_to_base_label
var connected_text = {true: 'Connected to our network', false: 'Not connected to mycelium'}
func update_connected_status():
	connected_to_base_label.text = "%s" % connected_text[_model._connected_to_base]

@onready var resources_label: Label = %resources_label
func update_resources():
	if not _model._connected_to_base:
		resources_label.text = "Available resources unknown, we need to touch it first"
		return
	resources_label.text = "Available resources: %s" % _model.get_resources_text()

@onready var in_out_labels: Array = [
	last_energy_input, last_enzymes_consumed, last_minerals_output
]
func update_input_output():
	last_energy_input.text = "Energy input: %0.4f" % _model.last_energy_input
	last_enzymes_consumed.text = "Enzymes consumed: %0.4f" % _model.last_enzymes_consumed
	last_minerals_output.text = "Minerals output: %0.4f" % _model.last_minerals_output
	if not _model._production_active:
		for label in in_out_labels:
			label.text = "Last %s" % label.text

@onready var production_efficiency_label: Label = %production_efficiency_label
func update_production_efficiency():
	production_efficiency_label.text = "Transformation efficiency: %0.2f%%" % (_model.get_value("production_efficiency") * 100)

@onready var missing_resources_for_full_capacity_label: Label = %missing_resources_for_full_capacity_label
func update_missing_resources():
	var value = _model.get_value("missing_resources_for_full_capacity")
	missing_resources_for_full_capacity_label.text = "%s" % missing_text[value]
var missing_text: Dictionary = {
	true: "Missing resources for optimal processing",
	false: ""
}

func _on_timer_timeout():
	if _model != null:
		update_data()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer = Timer.new()
	timer.wait_time = 1.0  # Set the timer to tick every second
	timer.autostart = true
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	visibility_changed.connect(_on_visibility_changed)
	# should read _model.is_production_active for button_pressed setter
	active_button.toggled.connect(_on_active_button_toggle)
	# connect to model state_changed to show or hide UI based on state change

# todo; on connection status changed

var active_button_text: Dictionary = {
	true: "Active",
	false: "Dormant",
}
func _on_active_button_toggle(toggled: bool):
	if _model == null:
		print_debug("Model not set")
		return
	var prev = _model._production_active
	if prev == toggled:
		return # nothing to change
	var change: Dictionary = {
		'type': 'UI',
		'prop': 'production',
		'structure': _model,
		'coords': _model.get_coords(),
		'curr': toggled,
		'prev': prev,
	}
	print_debug(change)
	_model.view_changed.emit(change)
	# change text
	active_button.text = active_button_text[toggled]

func _on_visibility_changed():
	if visible:
		timer.start()
	else:
		timer.stop()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
