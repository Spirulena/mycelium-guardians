extends Camera2D

@export var move_speed : float = 150
@export var zoom_amount : float = 1.25

var default_position: Vector2 = Vector2(-79, -139)
var reset_speed := 5.0

var is_following := false
var is_resetting := false

var playerUnit

func _ready():
	playerUnit = get_tree().get_first_node_in_group("Player")

func _process(delta):
	moveCamera(delta)
	zoomCamera(delta)
	handleFollow(delta)
	handleReset(delta)

func moveCamera(delta):
	var input = Input.get_vector("camera_left", "camera_right", "camera_up", "camera_down")
	var zoom_mod = 4 - zoom.x

	if input != Vector2.ZERO and is_following:
		is_following = false
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

func resetCamera():
	is_following = false
	is_resetting = true
	
	var tween = create_tween()
	tween.tween_property(self, "global_position", default_position, 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.finished.connect(func():
		is_resetting = false
	)
	
func handleReset(delta):
	if is_resetting:
		global_position = global_position.lerp(default_position, reset_speed * delta)
		
		if global_position.distance_to(default_position) < 1:
			global_position = default_position
			is_resetting = false

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
	
