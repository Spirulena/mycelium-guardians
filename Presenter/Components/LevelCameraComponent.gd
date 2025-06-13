class_name LevelCameraComponent extends ViewComponent

@export var jump_to_selected_colony : bool = true
@export var limit_min: Vector2 = Vector2(-10000, -10000)
@export var limit_max: Vector2 = Vector2(10000, 10000)
# Maximum speed for regular movement
@export var MAX_SPEED = 1000

@export var zoom_speed: float = 0.05
@export var min_zoom: float = 0.2
@export var max_zoom: float = 1.5

@onready var camera2d: Camera2D

# Threshold to determine if the camera is close enough to target
const CLOSE_ENOUGH = 5.0  # You can adjust this value based on your requirements

var new_position : Vector2 = Vector2()
# Acceleration and current speed
var ACCELERATION = 3000 # The rate of acceleration in pixels/second^2
# Adjusted deceleration to be more gradual
var DECELERATION = 2000  # Deceleration rate in pixels/second^2, adjust as needed

var current_speed_x = 0.0  # Current speed in X direction
var current_speed_y = 0.0  # Current speed in Y direction

var dragSensitivity: float = 1.0
var move_with_keys_enabled: bool = true
var zoom_sensitivity = 10
var events = {}
var last_drag_distance = 0

var drag_direction = - Vector2.ZERO
var dragging : bool = false
var drag_disabled : bool = false
var zoom_disabled : bool = false

# Flag to determine if the camera is auto moving to a target position
var is_auto_moving = false
# Target position to move to when auto moving
var target_position = Vector2()
#@onready var godot_essentials_shake_camera_component_2d = $GodotEssentialsShakeCameraComponent2D
var mouse_drag: bool = false

func _ready() -> void:
	y_sort_enabled = true
	z_index = 0
	z_as_relative = true

	# TODO: can remove container, component is the container

	camera2d = Camera2D.new()
	add_child(camera2d)
	camera2d.enabled = true

# Old copied from camera2d scene

# 5.0, 2.0; *1.5
func _on_camera_shake_request(strength: float, fade: float):
	pass
	# NOTE: testing Camera2D+
	#add_shake(strength) - that didint work. Maybe our process in camera overrides what they try to do
	# NOTE: removed 2d essentials plugin for now,
	#godot_essentials_shake_camera_component_2d.shake(strength, fade)

func _on_change_move_with_keys_state(new_enabled: bool):
	move_with_keys_enabled = new_enabled

func zoom_in_requested():
	if zoom_disabled:
		return
	camera2d.zoom += Vector2(zoom_speed, zoom_speed)
	camera2d.zoom = clamp(camera2d.zoom, Vector2(min_zoom, min_zoom), Vector2(max_zoom, max_zoom))

func zoom_out_requested():
	if zoom_disabled:
		return
	camera2d.zoom -= Vector2(zoom_speed, zoom_speed)
	camera2d.zoom = clamp(camera2d.zoom, Vector2(min_zoom, min_zoom), Vector2(max_zoom, max_zoom))

func zoom_reset_requested():
	if zoom_disabled:
		return
	camera2d.zoom = Vector2.ONE

func handle_mouse_drag2(event_relative):
	mouse_drag = true
	new_position -= event_relative * dragSensitivity / camera2d.zoom

func handle_mouse_drag(event_relative):
	mouse_drag = true
	# Calculate the target position based on drag but do not immediately set it
	var drag_target_position = camera2d.position - event_relative * dragSensitivity / camera2d.zoom
	new_position = drag_target_position#.clamp(limit_min, limit_max)

func move_to_position(requested_position: Vector2):
	# Set target position and enable auto moving
	target_position = requested_position
	new_position = target_position
	is_auto_moving = true

func move_to_base():
	move_to_position(_view.to_position(_lc.level_data.get_base_coords()[0]))

func get_movement_vector():
	var movement_vector = Vector2.ZERO
	if not move_with_keys_enabled:
		return Vector2.ZERO
	var x_movement = Input.get_action_strength("map_right") - Input.get_action_strength("map_left")
	var y_movement = Input.get_action_strength("map_down") - Input.get_action_strength("map_up")

	return Vector2(x_movement, y_movement).normalized()

func _process(delta):
	# Have states, MovingToPosition, RegularControl
	if is_auto_moving:
		# Auto move towards the target position
		if camera2d.position.distance_to(target_position) < CLOSE_ENOUGH:
			# If close enough, stop auto moving
			is_auto_moving = false
		else:
			camera2d.position = camera2d.position.lerp(target_position, 1.0 - exp(-delta * 5))
	else:
		# Adjusted regular movement logic for acceleration
		var movement_vector = get_movement_vector()
		if movement_vector.x != 0:
			# Accelerate or decelerate in X direction
			current_speed_x += ACCELERATION * delta * movement_vector.x
		else:
			# Apply deceleration
			if current_speed_x > 0:
				current_speed_x -= DECELERATION * delta
				current_speed_x = max(current_speed_x, 0)  # Prevent going below 0
			elif current_speed_x < 0:
				current_speed_x += DECELERATION * delta
				current_speed_x = min(current_speed_x, 0)  # Prevent going above 0

		if movement_vector.y != 0:
			# Accelerate or decelerate in Y direction
			current_speed_y += ACCELERATION * delta * movement_vector.y
		else:
		# Apply deceleration
			if current_speed_y > 0:
				current_speed_y -= DECELERATION * delta
				current_speed_y = max(current_speed_y, 0)  # Prevent going below 0
			elif current_speed_y < 0:
				current_speed_y += DECELERATION * delta
				current_speed_y = min(current_speed_y, 0)  # Prevent going above 0
		# Clamp the speed to not exceed MAX_SPEED after acceleration or deceleration
		current_speed_x = clamp(current_speed_x, -MAX_SPEED, MAX_SPEED)
		current_speed_y = clamp(current_speed_y, -MAX_SPEED, MAX_SPEED)

		# Apply movement based on current speed
		var velocity = Vector2(current_speed_x, current_speed_y) * delta
		if not mouse_drag:
			new_position = camera2d.position + velocity
			camera2d.position = new_position
		else:
			camera2d.position = new_position
			#position = position.lerp(new_position, 0.55)
		mouse_drag = false
		#position = position.lerp(new_position, 1.0 - exp(-delta * 5))

func camera_shake(strenght, fade):
	# TODO: can add shake component by code.
	# its GodotEssentialsShakeCameraComponent2D
	# camera.godot_essentials_shake_camera_component_2d.shake(strength, fade)
	# shake assumes that camera is parent
	# ATM: there is _on_camera_shake_request(strenght, fade) in camera2d
	_on_camera_shake_request(strenght, fade)

# TODO: Move to camera component ?
# func handle_view_change(change)
# func handle_model_change(change)

func handle_view_change(change: Dictionary):
	if super.handle_view_change(change):
		return

	if (change.type == 'Zoom'):
		if change.curr == "reset":
			zoom_reset_requested()
		elif change.curr == "in":
			zoom_in_requested()
		elif change.curr == "out":
			zoom_out_requested()

	elif (change.type == 'MouseDrag'):
		if change.curr != null:
			handle_mouse_drag(change.curr)
	elif (change.type == GUIController.Actions.GrowStructure):
		if change.state == 'placed':
			camera_shake(3.0, 5.0)

# Camera shake
# its using addon: 2dEssentials - currently disabled
# [] res://Scenes/controllers/camera_shake_ctrl/camera_shake_controller.tscn
