extends Camera2D

#@export var move_speed : float = 150
@export var pan_speed : float = .25
@export var zoom_amount : float = 1.25

var default_position: Vector2 = Vector2(-79, -139)
var reset_speed := .5

var is_following := false
var is_resetting := false

var playerUnit

var dragging = false
var last_mouse_position: Vector2

var move_cursor = preload("res://Alpha/2D assets/Cursors/move.png")
var default_cursor = preload("res://Alpha/2D assets/Cursors/arrow.png")

func _ready():
	Input.set_custom_mouse_cursor(default_cursor, Input.CURSOR_ARROW, Vector2(0, 0) )

	playerUnit = get_tree().get_first_node_in_group("Player")

func _process(delta):
	#moveCamera(delta)
	dragCamera(delta)
	zoomCamera(delta)
	handleFollow(delta)

func dragCamera(delta):
	if Input.is_action_just_pressed("camera_drag"):
		Input.set_custom_mouse_cursor(move_cursor, Input.CURSOR_ARROW, Vector2(0, 0))
		
		dragging = true
		last_mouse_position = get_viewport().get_mouse_position()
	elif Input.is_action_just_released("camera_drag"):
		dragging = false
		Input.set_custom_mouse_cursor(default_cursor, Input.CURSOR_ARROW, Vector2(0, 0))

	if dragging:
		var mouse_pos = get_viewport().get_mouse_position()
		var mouse_delta = mouse_pos - last_mouse_position

		var zoom_mod = 4 - zoom.x

		position -= mouse_delta * pan_speed * zoom_mod
		last_mouse_position = mouse_pos

#func moveCamera(delta):
	#var input = Input.get_vector("camera_left", "camera_right", "camera_up", "camera_down")
	#var zoom_mod = 4 - zoom.x
#
	#if input != Vector2.ZERO and is_following:
		#is_following = false
		#
	#global_position += input * delta * move_speed * zoom_mod

func zoomCamera(delta):
	var z = zoom.x
	
	if Input.is_action_just_released("camera_zoom_in"):
		z += zoom_amount

	elif Input.is_action_just_released("camera_zoom_out"):
		z -= zoom_amount
	
	z = clamp(z, 1, 3)
	
	zoom.x = z
	zoom.y = z

func resetCamera():
	is_following = false
	is_resetting = true
	
	var default_zoom := Vector2(1.25, 1.25)
	
	var tween = create_tween()
	tween.tween_property(self, "global_position", default_position, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "zoom", default_zoom, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	tween.finished.connect(func():
		is_resetting = false
	)

func handleFollow(delta):
	if is_resetting:
		return
	if is_following and playerUnit:
		global_position = playerUnit.global_position

func followUnit():
	if not playerUnit:
		return
	
	is_following = !is_following
	
	if is_following:
		global_position = playerUnit.global_position
	
