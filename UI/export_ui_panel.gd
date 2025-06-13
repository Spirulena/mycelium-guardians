extends PanelContainer

var _model: BuildingObject # export building for now
var _lc: LevelController
var _timer: Timer

# ui elements
@onready var export_do_button: Button = %ExportDoButton
@onready var grown_v_box_container: VBoxContainer = %GrownVBoxContainer
@onready var growing_v_box_container: VBoxContainer = %GrowingVBoxContainer
@onready var expand_radius: Button = %expand_radius


@export var parent: GUIController

func init(model):
	if _model != null:
		_model.state_changed.disconnect(_on_state_changed)
	_model = model
	_model.state_changed.connect(_on_state_changed)

	# is this needed ?
	radius_h_slider.value = _model.radius
	grown_growing_update()
	update_radius()
	update_data()

func _ready() -> void:
	_lc = LevelController.get_level_controller()
	_timer = Timer.new()
	_timer.wait_time = 1
	_timer.autostart = false
	_timer.name = "Tick"
	_timer.timeout.connect(_on_timer_timeout)
	add_child(_timer)

	# Execute button
	export_do_button.pressed.connect(_on_export_do_button_pressed)
	collect_carbon_button.pressed.connect(_on_collect_carbon_button_pressed)

	# sliders: radius, water, minerals.
	radius_h_slider.drag_ended.connect(_on_radius_h_slider_drag_ended)
	water_h_slider.drag_ended.connect(_on_water_h_slider_drag_ended)
	minerals_h_slider.drag_ended.connect(_on_minerals_h_slider_drag_ended)

	visibility_changed.connect(_on_visibility_changed)
	expand_radius.pressed.connect(_on_expand_radius_pressed)

func _on_expand_radius_pressed():
	# hide button when already covering ?
	var change: Dictionary = {
		'type': 'UI',
		'prop': 'export_expand_radius',
		'model': _model,
		'curr': true,
		'prev': null,
	}
	# view_changed, direct ?
	_model.view_changed.emit(change)

func _on_water_h_slider_drag_ended(value_changed: bool):
	if value_changed:
		_model.desired_resource_levels[ResourceObject.ResourceType.Water] = water_h_slider.value
		update_desired_resource_levels()

func _on_minerals_h_slider_drag_ended(value_changed: bool):
	if value_changed:
		_model.desired_resource_levels[ResourceObject.ResourceType.Minerals] = minerals_h_slider.value
		update_desired_resource_levels()

func _on_export_do_button_pressed():
	var prev = _model.export_enabled
	_model.export_enabled = !_model.export_enabled
	var change: Dictionary = {
		'type': 'UI',
		'prop': 'export',
		'model': _model,
		'curr': _model.export_enabled,
		'prev': prev,
	}
	# view_changed, direct ?
	_model.view_changed.emit(change)
	update_export_status()

@onready var collect_carbon_button: Button = %CollectCarbonButton
func _on_collect_carbon_button_pressed():
	var change: Dictionary = {
		'type': 'UI',
		'prop': 'import',
		'model': _model,
		'curr': true,
		'prev': false,
	}
	# view_changed, direct ?
	_model.view_changed.emit(change)
	update_carbon_display()

func _on_visibility_changed():
	if visible:
		_timer.start()
	else:
		_timer.stop()

func _on_timer_timeout():
	if _model == null:
		return
	update_data()

@onready var coords: Label = %Coords
@onready var number_of_tiles: Label = %NumberOfTiles
@onready var export_status_label: Label = %ExportStatusLabel
var export_status_text: Dictionary = { true: "Exporting", false: "Not exporting"}
var export_button_text: Dictionary = { true: "Stop Export", false: "Start Export"}
func update_data():
	coords.text = "[%d, %d]" % [_model.get_coords().x, _model.get_coords().y]
	# num tiles
	number_of_tiles.text = "Tiles: %d" % _model.export_tiles_amount
	# button
	update_export_status()
	update_resource_levels()
	update_desired_resource_levels()
	update_radius()
	update_carbon_display()
	update_smog_penalty_display()

@onready var carbon_display: Label = %CarbonDisplay
func update_carbon_display():
	var total_carbon = _model.total_accumulated_carbon # TODO: change that or just hide
	# then also hide collect carbon and add memo on using sclerotia
	# Assuming you have a Label node with the path "CarbonDisplay" for showing the total carbon
	carbon_display.text = "Accumulated Carbon: %.2f" % total_carbon

@onready var smog_penatly: Label = %SmogPenatly
func update_smog_penalty_display():
	var penalty_percent = _model.smog_penalty_percent_avg
	smog_penatly.text = "Smog Reduction: -%0.2f%%" % penalty_percent

@onready var water_amount_display: Label = %WaterAmountDisplay
@onready var water_h_slider: HSlider = %WaterHSlider
@onready var minerals_amount_display: Label = %MineralsAmountDisplay
@onready var minerals_h_slider: HSlider = %MineralsHSlider
func update_desired_resource_levels():
	water_amount_display.text = "%d" % _model.desired_resource_levels[ResourceObject.ResourceType.Water]
	#water_h_slider.value = int(_model.desired_resource_levels[ResourceObject.ResourceType.Water])
	minerals_amount_display.text = "%d" % _model.desired_resource_levels[ResourceObject.ResourceType.Minerals]
	#minerals_h_slider.value = int(_model.desired_resource_levels[ResourceObject.ResourceType.Minerals])

@onready var water_progress_bar: ProgressBar = %WaterProgressBar
@onready var minerals_progress_bar: ProgressBar = %MineralsProgressBar
func update_resource_levels():
	water_progress_bar.value = _model.export_resource_levels_percent[ResourceObject.ResourceType.Water]
	minerals_progress_bar.value = _model.export_resource_levels_percent[ResourceObject.ResourceType.Minerals]

func update_export_status():
	export_status_label.text = "Status: %s" % export_status_text[_model.export_enabled]
	export_do_button.text = export_button_text[_model.export_enabled]

@onready var radius_label: Label = %RadiusLabel
@onready var radius_h_slider: HSlider = %RadiusHSlider
func update_radius():
	radius_label.text = "Radius: %d" % _model.radius

func _on_radius_h_slider_drag_ended(value_changed: bool):
	if value_changed:
		radius_label.text = "Radius: %d" % radius_h_slider.value
		# TODO: use setter
		_model.set_value('radius', int(radius_h_slider.value))

func grown_growing_update():
	grown_v_box_container.visible = _model.get_state() == BuildingObject.BuildingState.Done
	growing_v_box_container.visible = _model.get_state() == BuildingObject.BuildingState.Building

func _on_state_changed(change):
	if change.prop == 'state' and change.curr == BuildingObject.BuildingState.Done:
		grown_v_box_container.show()
		growing_v_box_container.hide()
