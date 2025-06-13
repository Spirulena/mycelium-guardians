class_name HarvesterMapPresenter extends Node2D

var _model: HarvesterObject
var _parent

func _init(model, parent):
	_model = model
	_parent = parent
	_model.state_changed.connect(_state_changed)
	name = "HarvesterMapPresenter_%d_%d" % [_model.get_coords().x, _model.get_coords().y]

func _ready():
	# layer, coords, source_id, atlas_coords, alternative_tile
	var data = [0, _model.get_coords(), 0, Vector2i(0, 0)]
	add_child(HarvesterController.new(_model))

func _panel_changed(change):
	pass

func _state_changed(change):
	if change.type == ModelObject.Type.Harvester and change.curr == ModelObject.State.Removed:
		queue_free()

# Add progress bars here ? or just drive them in ruins scene
