class_name StructurePacingRadius extends Node2D

@onready var effect_radius: TileMap = $effect_radius


@onready var player: AnimationPlayer = $"AnimationPlayer"
@onready var circle: Sprite2D = $"Circle05"

@export var is_flashing: bool = false:
	set(value):
		if is_flashing != value:
			is_flashing = value
			flashing.emit(value)

signal flashing(state: bool)

var cell_size = Vector2i(256, 128)  # This should be replaced with your actual cell size
var line_width: float = 3.0
var color: Color = Color.DARK_BLUE
@export var radius: int = 0 ## cells_around_center

var _size: int

func _ready():
	_size = 0
	queue_redraw()
	flashing.connect(_on_flashing_change)

func show_effect_radius():
	effect_radius.show()
	show()

func hide_effect_radius():
	effect_radius.hide()
	hide()

func blink_failed():
	var tween: Tween = effect_radius.create_tween()
	tween.tween_property(effect_radius, "scale", Vector2(0.9, 0.9), 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT).from(Vector2.ONE)
	tween.tween_property(effect_radius, "scale", Vector2(1, 1), 0.1).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN_OUT)
	var tween_a: Tween = effect_radius.create_tween()
	tween_a.tween_property(effect_radius, "modulate", Color.RED, 0.2).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)
	tween_a.tween_property(effect_radius, "modulate", Color.WHITE, 0.2).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)
	var tween_r: Tween = effect_radius.create_tween()
	effect_radius.rotation_degrees = 0
	tween_r.tween_property(effect_radius, "rotation_degrees", -2, 0.2).from(0).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)
	tween_r.tween_property(effect_radius, "rotation_degrees", +2, 0.2).from(-2).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)
	tween_r.tween_property(effect_radius, "rotation_degrees", 0, 0.1).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)


func set_effect_radius(coords_list: Array[Vector2i]):# could pass whole change, co can check radius size change

	effect_radius.clear()
	for coords in coords_list:
		effect_radius.set_cell(0, coords + Vector2i(-1, 0), 0, Vector2i(0, 4))

	var new_size = coords_list.size()
	if new_size > _size:
		_size = new_size
		var tween: Tween = effect_radius.create_tween()
		tween.tween_property(effect_radius, "scale", Vector2(1.1, 1.1), 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT).from(Vector2.ONE)
		tween.tween_property(effect_radius, "scale", Vector2(1, 1), 0.1).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN_OUT)
		var tween_a: Tween = effect_radius.create_tween()
		tween_a.tween_property(effect_radius, "modulate:a", 0.3, 0.2).from(1.0).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)
		tween_a.tween_property(effect_radius, "modulate:a", 1.0, 0.2).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)
		
		var tween_r: Tween = effect_radius.create_tween()
		tween_r.tween_property(effect_radius, "rotation", 360*4, 0.09).from(0).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)
		tween_r.tween_property(effect_radius, "rotation", 0, 0.15).from(360*4).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)

	elif new_size < _size:
		_size = new_size
		var tween: Tween = effect_radius.create_tween()
		tween.tween_property(effect_radius, "scale", Vector2(0.9, 0.9), 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT).from(Vector2.ONE)
		tween.tween_property(effect_radius, "scale", Vector2(1, 1), 0.1).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN_OUT)
		var tween_a: Tween = effect_radius.create_tween()
		tween_a.tween_property(effect_radius, "modulate:a", 0.8, 0.2).from(1.0).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)
		tween_a.tween_property(effect_radius, "modulate:a", 1.0, 0.1).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)
		pass # smaller


func _on_flashing_change(state: bool):
	if state:
		player.play("flash")
		circle.show()
	else:
		player.stop()
		circle.hide()

func _draw():
	draw_isometric_rectangle(radius, cell_size, color, line_width)

func draw_isometric_rectangle(cells_around_center: int, cell_size: Vector2i, color: Color, line_width: float = 1.0):
	var total_cells = 2 * cells_around_center + 1  # Total number of cells on one side
	var size = cell_size * total_cells  # The size of the entire isometric rectangle

	var half_width = size.x / 2
	var half_height = size.y / 2

	var points = [
		Vector2(-half_width, 0),  # Left point
		Vector2(0, half_height),  # Bottom point
		Vector2(half_width, 0),  # Right point
		Vector2(0, -half_height)  # Top point
	]

	draw_line(points[0], points[1], color, line_width)  # Left-bottom side
	draw_line(points[1], points[2], color, line_width)  # Bottom-right side
	draw_line(points[2], points[3], color, line_width)  # Right-top side
	draw_line(points[3], points[0], color, line_width)  # Top-left side

