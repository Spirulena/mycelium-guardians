class_name AIPanelMapPresenter extends Node2D

var _model
var _parent
var _panels_tile_map

func _init(model, parent, panels_tile_map):
	_model = model
	_parent = parent
	_panels_tile_map = panels_tile_map
	_model.state_changed.connect(_panel_state_changed)

func _ready():
	# layer, coords, source_id, atlas_coords, alternative_tile
	var data = [0, _model.get_coords(), 0, Vector2i(0, 0)]
	_panels_tile_map.set_cell.callv(data)
	add_child(HealthController.new(_model))

func _panel_state_changed(change):
	if change.curr == ModelObject.State.Removed:
		_panels_tile_map.erase_cell(0, _model.get_coords())
