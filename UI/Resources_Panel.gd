extends PanelContainer

# TODO:
# Progress bar indicating amount / capacity ratio
# And number value for amount

# TODO: in default view, just both resources total.
# Ignore what is in sclerotia

@onready var h2o_label : Label = %h2o_label
@onready var energy_label : Label = %energy_label
@onready var minerals_label : Label = %minerals_label
@onready var carbon_label : Label = %carbon_label
@onready var acid_label : Label = Label.new()
@onready var enzymes_label: Label = %enzymes_label
@onready var acid_progress_bar : ProgressBar = ProgressBar.new()


@onready var value_labels: Dictionary = {
	ResourceObject.ResourceType.Water: h2o_label,
	ResourceObject.ResourceType.Energy: energy_label,
	ResourceObject.ResourceType.Minerals: minerals_label,
	ResourceObject.ResourceType.Carbon: carbon_label,
	ResourceObject.ResourceType.Acid: acid_label,
	ResourceObject.ResourceType.Enzymes: enzymes_label,
}
@onready var water_storage_label = %water_storage_label
@onready var energy_storage_label = %energy_storage_label
@onready var minerals_storage_label = %minerals_storage_label
@onready var carbon_storage_label = %carbon_storage_label
@onready var enzymes_storage_label: Label = %enzymes_storage_label

@onready var storage_labels: Dictionary = {
	   ResourceObject.ResourceType.Water: water_storage_label,
	   ResourceObject.ResourceType.Energy: energy_storage_label,
	   ResourceObject.ResourceType.Minerals: minerals_storage_label,
	   ResourceObject.ResourceType.Carbon: carbon_storage_label,
	   ResourceObject.ResourceType.Acid: acid_label,
	   ResourceObject.ResourceType.Enzymes: enzymes_storage_label,
}

# storage progress_bars
@onready var water_storage_progress_bar: ProgressBar = %water_storage_ProgressBar
@onready var energy_storage_progress_bar: ProgressBar = %energy_storage_ProgressBar
@onready var minerals_storage_progress_bar: ProgressBar = %minerals_storage_ProgressBar
@onready var carbon_storage_progress_bar: ProgressBar = %carbon_storage_ProgressBar
@onready var enzymes_storage_progress_bar: ProgressBar = %enzymes_storage_ProgressBar

@onready var storage_progress_bars: Dictionary = {
	   ResourceObject.ResourceType.Water: water_storage_progress_bar,
	   ResourceObject.ResourceType.Energy: energy_storage_progress_bar,
	   ResourceObject.ResourceType.Minerals: minerals_storage_progress_bar,
	   ResourceObject.ResourceType.Carbon: carbon_storage_progress_bar,
	   ResourceObject.ResourceType.Acid: acid_progress_bar,
	   ResourceObject.ResourceType.Enzymes: enzymes_storage_progress_bar,
}

@onready var water_trend: TextureRect = %h2o_trend
@onready var energy_trend: TextureRect = %energy_trend
@onready var minerals_trend: TextureRect = %minerals_trend
@onready var carbon_trend: TextureRect = %carbon_trend
@onready var enzymes_trend: TextureRect = %enzymes_trend

@onready var trend_icon: Dictionary = {
	ResourceObject.ResourceType.Water: water_trend,
	ResourceObject.ResourceType.Energy: energy_trend,
	ResourceObject.ResourceType.Minerals: minerals_trend,
	ResourceObject.ResourceType.Carbon: carbon_trend,
	ResourceObject.ResourceType.Acid: acid_label,
	ResourceObject.ResourceType.Enzymes: enzymes_trend,
}

var _lc: LevelController

var timer: Timer
func _ready():
	_lc = LevelController.get_level_controller()
	timer = Timer.new()
	timer.wait_time = 1.0  # Set the timer to tick every second
	timer.autostart = true
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)

@export var trend_icon_textures: Array[Texture2D]
var trend_text_to_id: Dictionary = {
	'stable': 0,
	'increasing': 1,
	'decreasing': 2,
}

func resource_changed(change):
	update_resource_label(change.resource, change.prev, change.curr)

func resource_limit_changed(change):
	update_resource_storage_label(change.resource_type, change.prev, change.curr)

func update_resource_label(type: ResourceObject.ResourceType, from, to):
	set_label_text(to, value_labels[type])

	var percent = to / max(1, _lc.get_tally_storage_limit(type)) * 100
	storage_progress_bars[type].value = percent

func update_resource_storage_label(type: ResourceObject.ResourceType, from, to):
	set_label_text(to, storage_labels[type])

func _on_timer_timeout():
	pass

# 0.2ms of frame time
func set_label_text(value: float, label):
	label.text = str("%0.0f" % [
		value,
	])
