extends Control

@export var _parent: GUIController
var _lc: LevelController
var _timer: Timer

# labels
@onready var mycelium_tiles_amount_label: Label = $PanelContainer/MarginContainer/VBoxContainer/mycelium_tiles_amount_label
@onready var environmental_bonus: Label = $PanelContainer/MarginContainer/VBoxContainer/environmental_bonus
@onready var water_bonus: Label = $PanelContainer/MarginContainer/VBoxContainer/water_bonus
@onready var production_bonus_due_to_water_label: Label = %production_bonus_due_to_water_label
@onready var energy_input_label: Label = $PanelContainer/MarginContainer/VBoxContainer/energy_input_label
@onready var production_percent_label: Label = $PanelContainer/MarginContainer/VBoxContainer/ProductionPercentLabel
@onready var last_enzyme_output: Label = %last_enzyme_output
@onready var efficiency_label: Label = %efficiency_label
@onready var production_h_slider: HSlider = %ProductionHSlider

func _ready() -> void:
	_lc = LevelController.get_level_controller()
	_timer = Timer.new()
	_timer.wait_time = 1
	_timer.autostart = true
	_timer.name = "Tick"
	_timer.timeout.connect(_on_timer_timeout)
	add_child(_timer)
	production_h_slider.drag_ended.connect(_on_production_drag_ended)
	update_data()
	visibility_changed.connect(_on_visibility_changed)

func _on_visibility_changed():
	if visible:
		_timer.start()
	else:
		_timer.stop()

func _on_production_drag_ended(value_changed: bool):
	if value_changed:
		production_percent_label.text = "Production: %d%%" % production_h_slider.value
		# emit change to ? view_changed -> level_presenter -> model_changed -> enzyme_controller
		# or just update_data() ?
		_lc.set_enzymes("production_percent", float(production_h_slider.value))

func _on_timer_timeout():
	update_data()

func update_data():
	mycelium_tiles_amount_label.text = "Mycelium tiles : %d" % _lc.get_all_mycelium().size()
	environmental_bonus.text = "Environmental bonus: %.2f" % _lc.get_enzymes("last_environmental_bonus")
	water_bonus.text = "- Water Bonus: %d%%" % _lc.get_enzymes("last_water_bonus")
	water_bonus.tooltip_text = "Water Bonus: Your expansion into water-rich territories has enhanced the local ecosystem. Current water availability increases enzyme production efficiency by +%d%%." % _lc.get_enzymes("last_water_bonus")
	production_bonus_due_to_water_label.text = "- Hydration Bonus: %d%%" % _lc.get_enzymes("production_bonus_due_to_water")
	production_bonus_due_to_water_label.tooltip_text = "Hydro Bonus: This bonus rewards your strategic expansion into water-rich tiles, granting a +%d%% increase in enzyme production for effectively utilizing these areas." % _lc.get_enzymes("production_bonus_due_to_water")
	energy_input_label.text = "Energy input: %.04f" % _lc.get_enzymes("last_energy_input")
	production_percent_label.text = "Production: %d%%" % production_h_slider.value
	last_enzyme_output.text = "Enzymes output: %.2f" % _lc.get_enzymes("last_enzyme_output")
	efficiency_label.text = "Efficiency: %d%%" % _lc.get_enzymes("efficiency")

	#_enzymes.set("last_environmental_bonus", 12)
	##_enzymes.last_environmental_bonus = 0
	#_enzymes.last_water_bonus = 0
	#_enzymes.last_energy_input = 0
	#_enzymes.production_percent = 50
	#_enzymes.last_enzyme_output = 0
	#_enzymes.efficiency = 0
