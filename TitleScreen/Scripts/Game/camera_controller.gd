extends Camera2D

@export var move_speed : float = 1200
@export var pan_speed  : float = 1.0

@export var zoom_step := 0.1
@export var min_zoom  := 0.08
@export var max_zoom  := 1.0

var default_position: Vector2 = Vector2(0, 0)

var is_following := false
var is_resetting := false

var playerUnit

var dragging := false
var last_mouse_position: Vector2

var move_cursor    = preload("res://Alpha/Core/Presenters/Cursors/move.png")
var default_cursor = preload("res://Alpha/Core/Presenters/Cursors/arrow.png")

func _ready():
	make_current()
	zoom = Vector2(0.25, 0.25)
	Input.set_custom_mouse_cursor(default_cursor, Input.CURSOR_ARROW, Vector2.ZERO)
	playerUnit = get_tree().get_first_node_in_group("Player")

func _process(delta):
	moveCamera(delta)
	dragCamera(delta)
	zoomCamera()

func dragCamera(delta):
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
		global_position -= mouse_delta * pan_speed / zoom.x
		last_mouse_position = mouse_pos

func moveCamera(delta):
	var input = Input.get_vector("camera_left", "camera_right", "camera_up", "camera_down")

	if input != Vector2.ZERO and is_following:
		is_following = false

	global_position += input * move_speed * delta / zoom.x

func zoomCamera():
	var z := zoom.x

	if Input.is_action_just_pressed("camera_zoom_in"):
		z += zoom_step

	elif Input.is_action_just_pressed("camera_zoom_out"):
		z -= zoom_step

	z = clamp(z, min_zoom, max_zoom)
	zoom = Vector2(z, z)
