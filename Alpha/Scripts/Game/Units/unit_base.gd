extends Area2D
class_name Unit

var groundLayer: TileMapLayer
var obstacleLayer: Array[TileMapLayer]

const tile_size : Vector2 = Vector2(64, 32)

@export var move_speed : float = 100
@export var arrival_threshold: float = 1.0

enum Team {Player, AI}
@export var team : Team

var target_position: Vector2
var path: PackedVector2Array
var is_moving: bool = false

@export var trail_scene: PackedScene
var trail_instance: Node2D
@export var trailPathToggle: bool = true
var last_trail_tile: Vector2 = Vector2.INF
var trail_tiles := {}

func _ready():
	groundLayer = TilemapGrid.instance.groundLayer
	obstacleLayer = TilemapGrid.instance.obstacleLayer
	var tile_size = Vector2(64, 32)

func snap_to_isometric(position: Vector2, tile_size_variable: Vector2) -> Vector2:
	var half_tile_size: Vector2 = tile_size_variable * .5
	
	var grid_x: float = round((position.x / half_tile_size.x + position.y / half_tile_size.y) * .5)
	var grid_y: float = round((position.y / half_tile_size.y - position.x / half_tile_size.x) * .5)
	
	return Vector2(grid_x-grid_y, grid_x+grid_y) * half_tile_size

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			var click_pos = get_global_mouse_position()
			#print("\nNew movement requested")
			#print("From: ", global_position)
			#print("To: ", click_pos)
			
			var new_path = MovementUtils.get_path_to_tile(
				global_position,
				click_pos,
				groundLayer,
				obstacleLayer
			)
			
			if not new_path.is_empty():
				path = new_path
				is_moving = true
				target_position = path[0]
				#print("Path accepted, first target: ", target_position)
				
				var tile_highlight_controller = get_parent().get_node("Tilemap")
				
				if tile_highlight_controller:
					tile_highlight_controller.show_destination_highlight(path[-1])
				
				if target_position.distance_to(global_position) < arrival_threshold:
					print("Warning: First target too close to current position!")
					_advance_to_next_target()
			else:
				pass
				print("Path was empty, movement cancelled")

func _physics_process(delta: float) -> void:
	if not is_moving or path.is_empty():
		return
		
	var distance_to_target = global_position.distance_to(target_position)
	#print("Distance to target: ", distance_to_target)
	
	if distance_to_target < arrival_threshold:
		global_position = target_position
		_advance_to_next_target()
	else:
		var direction = (target_position - global_position).normalized()
		var movement = direction * move_speed * delta
		if movement.length() > distance_to_target:
			movement = direction * distance_to_target
		global_position += movement
		#print("Moving: dir=", direction, " movement=", movement, " new_pos=", global_position)
	
		_try_spawn_trail()

func _advance_to_next_target() -> void:
	path.remove_at(0)
	#print("Point reached, remaining points: ", path.size())
	
	if path.is_empty():
		#print("Path completed")
		is_moving = false
		
		var tile_highlight_controller = get_parent().get_node("Tilemap")
		if tile_highlight_controller:
			tile_highlight_controller.remove_destination_highlight()
		
		return
		
	target_position = path[0]
	if target_position.distance_to(global_position) < arrival_threshold:
		print("Next target too close, skipping")
		_advance_to_next_target()
	else:
		pass
		#print("New target set: ", target_position)

func _try_spawn_trail():
	if not trailPathToggle:
		return

	var local_pos = groundLayer.to_local(global_position)
	var snapped_local = snap_to_isometric(local_pos, tile_size)
	var snapped_global = groundLayer.to_global(snapped_local)

	if snapped_global == last_trail_tile:
		return

	if last_trail_tile != Vector2.INF and not trail_tiles.has(last_trail_tile):
		if trail_scene:
			var trail = trail_scene.instantiate()
			trail.global_position = last_trail_tile
			get_parent().add_child(trail)
			trail_tiles[last_trail_tile] = true 

	last_trail_tile = snapped_global
