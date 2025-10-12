extends Camera2D

@export var move_speed : float = 150
@export var zoom_amount : float = 1.25

func _process(delta):
	moveCamera(delta)
	zoomCamera(delta)

func moveCamera(delta):
	var input = Input.get_vector("camera_left", "camera_right", "camera_up", "camera_down")
	
	var zoom_mod = 4 - zoom.x
	
	global_position += input * delta * move_speed * zoom_mod

func zoomCamera(delta):
	var z = zoom.x
	
	if Input.is_action_just_released("camera_zoom_in"):
		z += zoom_amount
	elif Input.is_action_just_released("camera_zoom_out"):
		z -= zoom_amount
	
	z = clamp(z, 1, 3)
	
	zoom.x = z
	zoom.y = z
