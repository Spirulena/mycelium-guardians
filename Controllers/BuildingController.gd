class_name BuildingController extends Node2D

var _building: BuildingObject
var _lc: LevelController

func _init(building):
	_lc = LevelController.get_level_controller()
	_building = building
	_building.set_health(0)
	# If smog absorber add new controller
	name = "BuildingController_%d_%d" % [_building.get_coords().x, _building.get_coords().y]

func _ready():
	if _building.get_building_type() == BuildingObject.StructureType.Absorber_Smog:
		add_child(SmogAbsorberController.new(_building, _lc))
	elif _building.get_building_type() == BuildingObject.StructureType.Absorber_Radiation:
		add_child(RadiationAbsorberController.new(_building, _lc))
	elif _building.get_building_type() == BuildingObject.StructureType.Export_Center:
		add_child(ExportCenterController.new(_building, _lc))
	elif _building.get_building_type() == BuildingObject.StructureType.Storage_Carbon:
		add_child(StorageController.new(_building, _lc))
	elif _building.get_building_type() == BuildingObject.StructureType.Storage_Water:
		add_child(StorageController.new(_building, _lc))
	elif _building.get_building_type() == BuildingObject.StructureType.Storage_Minerals:
		add_child(StorageController.new(_building, _lc))
	elif _building.get_building_type() == BuildingObject.StructureType.Storage_Energy:
		add_child(StorageController.new(_building, _lc))
	_building.state_changed.connect(_on_state_changed)

func _on_state_changed(change):
	if change.prop == 'state' and change.curr == BuildingObject.BuildingState.Done:
		# apply storage to building
		if _building.get_category() == BuildingObject.StructureCategory.Storage:
			_building.apply_storage_limit()

var growth_speed_by_radius: Dictionary = {
	1: 1.2,
	2: 1.0,
	3: 0.8,
	4: 0.6,
	5: 0.4,
}

func _process(delta):
# move out of process ?
	if _building.get_state() == BuildingObject.BuildingState.Building:
		# Health as building status
		var health = _building.get_health()
		#  * growth_speed_by_radius[_model.get_radius()]
		var new_health = health + delta * 10  * growth_speed_by_radius[_building.get_radius()]
		# take deficit of resources into account

		_building.set_health(new_health)

		if new_health >= 100:
			_building.set_state(BuildingObject.BuildingState.Done)
	elif _building.get_state() == BuildingObject.BuildingState.Done:
		set_process(false)
		pass
