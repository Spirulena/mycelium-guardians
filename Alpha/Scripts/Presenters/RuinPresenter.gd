class_name RuinPresenter
extends Node2D

const TEXTURE_LOCATION = "res://Alpha/Core/Presenters/ObjectTextures/Structures/ruins/ruin1.png" #placeholder sprite

var _sprite: Sprite2D
var _model: RuinObject

func _init(model: RuinObject) -> void:
	_model = model

func _ready() -> void:
	_sprite = Sprite2D.new()
	_sprite.texture = load(TEXTURE_LOCATION)
	add_child(_sprite)
	
	# later replace with different textures
	#var size: Vector2i = _model.get_size()
	#if size.x > 1 or size.y > 1:
		#_sprite.scale = Vector2(size.x, size.y) * 0.5
	
	_model.state_changed.connect(_on_state_changed)
	_model.health_changed.connect(_on_health_changed)
	
	_on_state_changed({ "curr": _model.get_state() })
	_on_health_changed({ "curr": _model.get_health() })
	
	#print(
		#"[RuinPresenter]",
		#"type:", _model.get_ruin_type(),
		#"name:", _model._ruin_name,
		#"size:", _model.get_size(),
		#"resources:", _model.get_resources_text(),
		#"coords:", _model.get_coords()
	#)

func _on_health_changed(change: Dictionary) -> void:
	var health: float = float(change.curr)
	var t: float = clampf(health / 100.0, 0.35, 1.0)
	_sprite.modulate = Color(1, 1, 1, t)

func _on_state_changed(change: Dictionary) -> void:
	var new_state: String = change.curr
	
	match new_state:
		ModelObject.State.Crashed:
			_sprite.modulate = Color(0.4, 0.4, 0.4)
		ModelObject.State.Removed:
			queue_free()
		_:
			_sprite.modulate = Color.WHITE
