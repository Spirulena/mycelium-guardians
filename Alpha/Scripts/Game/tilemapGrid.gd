extends Node2D
class_name TilemapGrid
static var instance: TilemapGrid

@export var groundLayer: TileMapLayer
@export var obstacleLayer: Array[TileMapLayer]

var hover_effect: Polygon2D
@onready var hover_sprite: Sprite2D = $TileHighlight

@export var destination_hover_scene: PackedScene
var destination_hover: Sprite2D

@export var unit_selection_scene: PackedScene
var unit_selection: Sprite2D
var unit_highlights := {}

var current_selected_unit: Unit = null

const TILE_SIZE := Vector2(64, 32)

func _ready():
	instance = self
	setup_hover_polygon()

func _process(_delta: float) -> void:
	handle_hover_effect()
	
	for unit in unit_highlights.keys():
		update_unit_selection_position(unit)

func setup_hover_polygon() -> void:
	hover_effect = Polygon2D.new()
	hover_effect.polygon = PackedVector2Array([
		Vector2(0, -16),
		Vector2(32, 0),
		Vector2(0, 16),
		Vector2(-32, 0)
	])
	hover_effect.color = Color(1, 1, 1, 0.2)
	hover_effect.visible = false
	hover_effect.z_index = 1
	add_child(hover_effect)

func handle_hover_effect() -> void:
	var mouse_pos = get_local_mouse_position()
	var snapped_pos = snap_to_isometric(mouse_pos, TILE_SIZE)	
	var cell = groundLayer.local_to_map(snapped_pos)
	
	var has_ground = groundLayer.get_cell_source_id(cell) != -1
	var has_obstacle := false
	for layer in obstacleLayer:
		if layer.get_cell_source_id(cell) != -1:
			has_obstacle = true
			break
	
	if has_ground and not has_obstacle:
		var local_pos = groundLayer.map_to_local(cell)
		hover_sprite.position = local_pos
		hover_effect.position = local_pos
	
		if not hover_sprite.visible:
			hover_sprite.visible = true
			start_hover_pulse(hover_sprite)
		
		hover_effect.visible = true
	else:
		if hover_sprite.visible:
			stop_hover_pulse(hover_sprite)
		hover_effect.visible = false

func start_hover_pulse(node: CanvasItem, duration := 0.6):
	if node.has_meta("pulse_tween"):
		var existing_tween = node.get_meta("pulse_tween")
		if existing_tween.is_running():
			return
	
	var tween = create_tween()
	node.set_meta("pulse_tween", tween)
	
	node.modulate.a = 1.0
	tween.set_loops()
	tween.tween_property(node, "modulate:a", 0.1, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "modulate:a", 1.0, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func stop_hover_pulse(node: CanvasItem):
	if node.has_meta("pulse_tween"):
		var tween = node.get_meta("pulse_tween")
		if tween.is_running():
			tween.stop()
	node.modulate.a = 1.0
	node.visible = false
	node.set_meta("pulse_tween", null)

var destination_highlights := {}

func show_destination_highlight(unit: Unit, world_position: Vector2):
	if destination_highlights.has(unit):
		destination_highlights[unit].queue_free()
		destination_highlights.erase(unit)
	
	if destination_hover_scene:
		var highlight = destination_hover_scene.instantiate()
		get_parent().add_child(highlight)
		
		var local_pos = groundLayer.to_local(world_position)
		var snapped_local = snap_to_isometric(local_pos, TILE_SIZE)
		var snapped_global = groundLayer.to_global(snapped_local)
		
		highlight.global_position = snapped_global
		
		start_hover_pulse(highlight)
		
		destination_highlights[unit] = highlight
		
		destination_hover = highlight

func remove_destination_highlight(unit: Unit):
	if destination_highlights.has(unit):
		stop_hover_pulse(destination_highlights[unit])
		destination_highlights[unit].queue_free()
		destination_highlights.erase(unit)
		
	if destination_hover == null or not is_instance_valid(destination_hover):
		destination_hover = null

func show_unit_selection(unit: Unit):
	print("TilemapGrid: Show selection:", unit.name)
	
	if unit_highlights.has(unit):
		return
	
	if unit_selection_scene:
		var highlight = unit_selection_scene.instantiate()
		get_parent().add_child(highlight)
	
		highlight.global_position = unit.global_position
		start_hover_pulse(highlight)
	
		unit_highlights[unit] = highlight

func clear_unit_selection(unit: Unit):
	print("TilemapGrid: Clear selection:", unit.name)
	
	if unit_highlights.has(unit):
		var highlight = unit_highlights[unit]
		stop_hover_pulse(highlight)
		highlight.queue_free()
		unit_highlights.erase(unit)

func update_unit_selection_position(unit: Unit):
	if unit_highlights.has(unit):
		var highlight = unit_highlights[unit]
		highlight.global_position = unit.global_position

func snap_to_isometric(position: Vector2, tile_size_variable: Vector2) -> Vector2:
	var half_tile_size: Vector2 = tile_size_variable * 0.5
	
	var grid_x: float = round((position.x / half_tile_size.x + position.y / half_tile_size.y) * 0.5)
	var grid_y: float = round((position.y / half_tile_size.y - position.x / half_tile_size.x) * 0.5)
	
	return Vector2(grid_x - grid_y, grid_x + grid_y) * half_tile_size
