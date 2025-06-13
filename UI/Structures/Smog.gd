extends PanelContainer

@onready var _model: BuildingObject
@onready var _tile: TileObject
@onready var name_label: Label = %name_label
@onready var coords_label: Label = %coords_label
@onready var processing_tiles: Label = %processing_tiles
@onready var growing_state: Label = %growing_state

@onready var last_energy_input: Label = %last_energy_input
@onready var last_enzymes_consumed: Label = %last_enzymes_consumed
@onready var last_minerals_output: Label = %last_minerals_output
@onready var active_button: CheckButton = %active_button

var timer: Timer

func init(model, tile):
	if _model != null:
		_model.state_changed.disconnect(_on_state_changed)
	_model = model
	_tile = tile
	_model.state_changed.connect(_on_state_changed)

	radius_h_slider.value = _model.radius

	_init_visibility_on_building_status()
	update_data()
	#timer.start()

@onready var radius_label: Label = %RadiusLabel
@onready var radius_h_slider: HSlider = %RadiusHSlider
func update_radius():
	radius_label.text = "Radius: %d" % _model.radius

func _on_radius_h_slider_drag_ended(value_changed: bool):
	if value_changed:
		radius_label.text = "Radius: %d" % radius_h_slider.value
		# TODO: use setter
		_model.set_value('radius', int(radius_h_slider.value))

func update_data():
	update_radius()
	name_label.text = _model.get_structure_full_name()
	coords_label.text = "[%s, %s]" % [_model.get_coords().x, _model.get_coords().y]
	# Show growing progress bar.
	# Building Status -> String keys, to show in UI
	growing_status()
	#if _model.get_state() == BuildingObject.BuildingState.Done:
	update_input_output()
	set_processing_tiles(_model.processing_coords_amount)
	# TODO: add slider, how many tiles to process
	# value min 0, max processing_coords_amount.size()

	active_button.text = active_button_text[_model._production_active]
	active_button.button_pressed = _model._production_active
	update_production_efficiency()
	update_missing_resources()

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

func growing_status():
	if _model.get_state() == BuildingObject.BuildingState.Building:
		growing_state.show()
	else:
		growing_state.hide()

func set_processing_tiles(amount):
	processing_tiles.text = "Smog available to process in #%s tiles" % amount

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

	radius_h_slider.drag_ended.connect(_on_radius_h_slider_drag_ended)


@onready var grown: VBoxContainer = %grown
func _init_visibility_on_building_status():
	grown.hide()
	match _model.get_state():
		BuildingObject.BuildingState.Done:
			grown.show()

func _on_state_changed(change):
	if change.prop == 'state' and change.curr == BuildingObject.BuildingState.Done:
		grown.show()

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
