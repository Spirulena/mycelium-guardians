extends PanelContainer

@onready var overlays = %Overlays
@onready var all_overlays
@onready var smog = %Smog
@onready var radiation = %Radiation
@onready var mycelium_health = %MyceliumHealth
@onready var structure_health = %StructureHealth
@onready var hide_numbers = %HideNumbers
@onready var separator = $Overlays/separator
@onready var water = %Water
@onready var water_storage: TextureButton = %WaterStorage
@onready var energy_storage: TextureButton = %EnergyStorage
@onready var minerals_storage: TextureButton = %MineralsStorage
@onready var carbon_storage: TextureButton = %CarbonStorage



@export var parent: Node

# TODO: visually indicate which on is active
func _ready():
	overlays.pressed.connect(_on_overlay_pressed)
	# TODO: change to same as bottom menu buttons
	smog.pressed.connect(_on_overlay_reqested.bind(Overlay.OverlayType.Smog))
	radiation.pressed.connect(_on_overlay_reqested.bind(Overlay.OverlayType.Radiation))
	water.pressed.connect(_on_overlay_reqested.bind(Overlay.OverlayType.Water))
	water_storage.pressed.connect(_on_overlay_reqested.bind(Overlay.OverlayType.WaterStorage))
	energy_storage.pressed.connect(_on_overlay_reqested.bind(Overlay.OverlayType.EnergyStorage))
	minerals_storage.pressed.connect(_on_overlay_reqested.bind(Overlay.OverlayType.MineralsStorage))
	carbon_storage.pressed.connect(_on_overlay_reqested.bind(Overlay.OverlayType.CarbonStorage))

	mycelium_health.pressed.connect(_on_overlay_reqested.bind(Overlay.OverlayType.MyceliumHealth))
	structure_health.pressed.connect(_on_overlay_reqested.bind(Overlay.OverlayType.StructureHealth))
	hide_numbers.pressed.connect(_on_overlay_reqested.bind(Overlay.OverlayType.Numbers))
	#all_overlays = [smog, radiation, mycelium_health, hide_numbers, $Overlays/separator, $Overlays/Control2, $Overlays/Control3, $Overlays/Control5]
	all_overlays = [smog, radiation, water, water_storage, energy_storage, minerals_storage, carbon_storage, $Overlays/separator, $Overlays/Control2, $Overlays/Control3,$Overlays/Control7, $Overlays/Control8, $Overlays/Control9]
	_hide_all_overlays()

func _on_overlay_pressed():
	# hide all overleys
	var change: Dictionary = {
		# how should I query the current state aka. prev
		'prev': null,
		'curr': false,
		'type': 'Overlay',
		'toggle': false,
		'overlay_type': Overlay.OverlayType.All,
	}
	parent.view_changed.emit(change)

	for overlay in all_overlays:
		overlay.visible = !overlay.visible

func _hide_all_overlays():
	for overlay in all_overlays:
		overlay.visible = false

func _on_overlay_reqested(overlay_type: Overlay.OverlayType):
	var change: Dictionary = {
		# how should I query the current state aka. prev
		'prev': null,
		'curr': true,
		'type': 'Overlay',
		'overlay_type': overlay_type,
		'is_auto': false,
	}
	parent.view_changed.emit(change)
