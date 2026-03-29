extends Camera3D

@export var move_speed : float = 20.0
@export var pan_speed  : float = 0.02

@export var zoom_step  : float = 0.5
@export var min_size   : float = 2.0
@export var max_size   : float = 20.0

var is_following := false
var dragging := false
var last_mouse_position: Vector2

var move_cursor    = preload("res://Alpha/Core/UI/Cursors/move.png")
var default_cursor = preload("res://Alpha/Core/UI/Cursors/arrow.png")

func _ready():
	make_current()
	Input.set_custom_mouse_cursor(default_cursor, Input.CURSOR_ARROW, Vector2.ZERO)

func _process(delta):
	move_camera(delta)
	drag_camera()
	zoom_camera()

func drag_camera():
	if Input.is_action_just_pressed("camera_drag"):
		Input.set_custom_mouse_cursor(move_cursor, Input.CURSOR_ARROW, Vector2.ZERO)
		dragging = true
		is_following = false
		last_mouse_position = get_viewport().get_mouse_position()
	
	elif Input.is_action_just_released("camera_drag"):
		dragging = false
		Input.set_custom_mouse_cursor(default_cursor, Input.CURSOR_ARROW, Vector2.ZERO)
	
	if dragging:
		var mouse_pos = get_viewport().get_mouse_position()
		var mouse_delta = mouse_pos - last_mouse_position
		
		var right = transform.basis.x
		var forward = transform.basis.y
		
		right.y = 0
		forward.y = 0
		right = right.normalized()
		forward = forward.normalized()
	
		var move_vec = (right * mouse_delta.x) - (forward * mouse_delta.y)
		global_position -= move_vec * pan_speed * (size * 0.1)
		
		last_mouse_position = mouse_pos

func move_camera(delta):
	var input = Input.get_vector("camera_left", "camera_right", "camera_up", "camera_down")
	
	if input != Vector2.ZERO:
		is_following = false
		
		var right = transform.basis.x
		var forward = transform.basis.y
		right.y = 0
		forward.y = 0
		
		var direction = (right * input.x) + (forward * input.y)
		global_position += direction.normalized() * move_speed * delta * (size * 0.1)

func zoom_camera():
	if Input.is_action_just_pressed("camera_zoom_in"):
		size -= zoom_step
	elif Input.is_action_just_pressed("camera_zoom_out"):
		size += zoom_step
	
	size = clamp(size, min_size, max_size)
