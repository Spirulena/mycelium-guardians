class_name TutorialWater extends LevelView

var buildable: Dictionary
var tutorial_replay_component: TutorialReplayStepComponent
var camera_component: LevelCameraComponent
@onready var music_player: ViewComponent
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	buildable = {}
	# disable chance controller
	# disable enzymes controller, so we are not draining water
	# or drop enzymes slider to 0
	components_enable['HintsComponent'] = false
	components_enable['GroundPresenterComponent'] = true
	components_enable['TileDebugComponent'] = true
	components_enable['EnzymesComponent'] = false
	components_enable['SmogComponent'] = false
	components_enable['ChanceControllerComponent'] = false
	components_enable['MusicPlayerComponent'] = true # will trigger music in tutorial via animation or request

	# block out other resources ?

	# Add something to find on the map
	# Pond ruin ?
	# retention tank
	# swimming pool ?

	# animation, get water,
	# animation build water collector
	level_controller.level_data._base_coords = [Vector2i(0,0)]
	level_controller.set_buildable(buildable)
	super()
	level_controller.set_ignore_water_noise(false)
	init_mycelium()

	add_component_view_ignore('LevelCameraComponent', ['Zoom', 'MouseDrag'])
	# Hide UI elements
	game_ui_controller.hide_element('Overlay')
	game_ui_controller.hide_element('ResourcesPanel') # unhide after we tell about water
	game_ui_controller.hide_element('SideDebug')
	game_ui_controller.hide_element('BottomMenu') # Then show when instructing to build storage collector
	#game_ui_controller.hide_element('ZoomUI')
	game_ui_controller.set_handle_events(false) # tmp disable mouse handling

	game_ui_controller.set_show_overlay_hints(false)
	# ingore change in GUI for overlays hint
	# add var for now

	music_player = components.get("MusicPlayerComponent")
	# get camera
	camera_component = components.get("LevelCameraComponent")
	camera_component.move_with_keys_enabled = false
	camera_component.camera2d.zoom = Vector2(1, 1)
	camera_component.camera2d.position = Vector2(0, 0)
	#camera_component.camera2d.limit_right = 7000
	#camera_component.camera2d.limit_bottom = 3000
	#camera_component.camera2d.limit_left = -9000
	#camera_component.camera2d.limit_top = -7000
	tutorial_replay_component = TutorialReplayStepComponent.new(level_controller, self, game_ui_controller, 'TutorialReplayStepComponent')
	add_child(tutorial_replay_component)
	tutorial_replay_component.setup(replay_instructions, exit_instructions)

func init_mycelium():
	var mycelium_positions = level_controller.get_coords_in_circle(Vector2i(1,1), 1)
	 #= [Vector2i(-1, 11), ]
	for i in range(-1, 4):
		mycelium_positions.append(Vector2i(2, i))
	#for j in range(-3, 4):
		#mycelium_positions.append(Vector2i(j, 0))
	#for j in range(-2, 3):
		#mycelium_positions.append(Vector2i(j, -1))
	#for j in range(-5, 8):
		#mycelium_positions.append(Vector2i(j, -2))

	for coords in mycelium_positions:
		level_controller.add_object(MyceliumObject.new(coords))
		level_controller.get_tile_at(coords).set_discovered_in_radius(true, 4)

	#var seed_mycelium = level_controller.get_tile_at(mycelium_positions[0]).get_mycelium()
	#seed_mycelium.set_state(MyceliumObject.MyceliumState.Idle)
	#seed_mycelium.set_health(100)

	for coords in mycelium_positions:
		var seed_mycelium = level_controller.get_tile_at(coords).get_mycelium()
		seed_mycelium.set_state(MyceliumObject.MyceliumState.Idle)
		seed_mycelium.set_health(100)

func show_resource_panel():
	game_ui_controller.show_element('ResourcesPanel')

func show_storage_panel():
	pass

func show_bottom_menu():
	game_ui_controller.show_element('BottomMenu')

func preview_mycelium():
	start_click(Vector2i(2,1))
	for i in range(2, 15):
		await get_tree().create_timer(0.15).timeout
		move_press(Vector2i(i,1))

func exit_preview_mycelium():
	click_cancel()
	game_ui_controller.set_handle_events(false) # tmp disable mouse handling

func start_click(coords: Vector2i):
	var curr_action = GUIController.Actions.Explore
	game_ui_controller.set_current_action_mode(curr_action)
	game_ui_controller._mouse_controller._state_handlers[curr_action].handle_press(coords)

func move_press(coords: Vector2i):
	var curr_action = GUIController.Actions.Explore
	game_ui_controller._mouse_controller._state_handlers[curr_action].handle_move(coords)

func click_release(coords: Vector2i):
	var curr_action = GUIController.Actions.Explore
	game_ui_controller._mouse_controller._state_handlers[curr_action].handle_release(coords)

func click_cancel():
	var curr_action = GUIController.Actions.Explore
	game_ui_controller.set_selected(null)
	game_ui_controller._mouse_controller._state_handlers[curr_action].reset()


# 01
func replay_instructions():
	tutorial_replay_component.hide_replay_window()
	click_cancel()
	animation_player.play("01")

@onready var mycelium_grown_progress: TextureProgressBar = %MyceliumGrownProgress
@onready var mycelium_grown_label: Label = %MyceliumGrownLabel

@onready var _01: Label = $"CanvasLayer/Instructions/01"
func exit_instructions():
	tutorial_replay_component.hide_replay_window()
	# unblock zoom
	# drag
	var tween: Tween = _01.create_tween()
	tween.tween_property(_01, "modulate:a", 0.0, 2.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)

	camera_component.move_with_keys_enabled = true
	del_component_view_ignore('LevelCameraComponent', ['Zoom', 'MouseDrag'])
	click_cancel()
	game_ui_controller.set_handle_events(true) # re-enable mouse handling
	game_ui_controller.set_current_action_mode(game_ui_controller.default_action)
	game_ui_controller.set_selected(null) # or {'coords': coords,'tile': tile,}

	game_ui_controller.set_show_overlay_hints(true)
	# then listen to water extraction
	# or just timer until resource panel shown
	# or until mycelium reaches water ?
	# then show how to build storage collectors
	# setup next instructions
	mycelium_grown_progress.max_value = mycelium_target
	mycelium_grown_progress.value = 0
	mycelium_grown_label.text = "Expand Mycelium onto Water Tiles: 0/%d" % mycelium_target
	var tween_p: Tween = mycelium_grown_progress.create_tween()
	tween_p.tween_property(mycelium_grown_progress, "modulate:a", 1.0, 1.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC).from(0)

	# wait for mycelium,
	# and show the progress bar of new mycelium where water is
	# then model changes will trigger it
	pass
	#get_tree().create_timer(5).timeout.connect(animation_player.play.bind("02_resource_panel"))

	tutorial_replay_component.setup(replay_resource_instructions, exit_resource_instructions)

func replay_resource_instructions(): # show resource panel and mycelium cap
	tutorial_replay_component.hide_replay_window()
	animation_player.play("02_resource_panel")

@onready var _02: Label = %"02"
func exit_resource_instructions():
	finish_tutorial()


# block zoom for sec
# block drag
# get camera component
func zoom_out_camera():
	var tween: Tween = camera_component.camera2d.create_tween()
	var zoom_level: Vector2 = Vector2(0.5, 0.5)
	tween.tween_property(camera_component.camera2d, "zoom", zoom_level, 2.2).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	#camera_component.camera2d.zoom = Vector2(1, 1)

# shoudl this be a part of tutorial component
func show_tutorial_replay_window():
	tutorial_replay_component.show_replay_window()

@onready var grown_progress: TextureProgressBar = %GrownProgress
@onready var grown_label: Label = %GrownLabel

var mycelium_amount: int = 0
var mycelium_target: int = 20

var track_mycelium: bool = true
func _on_model_changed(change: Dictionary):
	super._on_model_changed(change)

	if change.type == ModelObject.Type.Mycelium:
		# New
		if change.prev == null:
			if not track_mycelium:
				return
			pass # count
			# scale up
			var value = clamp(level_controller.get_water_level(change.coords), 0, 1)
			if value >= 0.3:
				mycelium_amount += 1
				var tween_amount: Tween = mycelium_grown_progress.create_tween()
				tween_amount.tween_property(mycelium_grown_progress, "value", mycelium_amount, 0.1)
				#mycelium_grown_progress.value = mycelium_amount
				mycelium_grown_label.text = "Expand Mycelium onto Water Tiles: %d/%d" % [mycelium_amount, mycelium_target]
				if mycelium_amount > 0:
					# can scale up after each one
					var tween_m_i: Tween = mycelium_grown_progress.create_tween()
					tween_m_i.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
					tween_m_i.tween_property(mycelium_grown_progress, "scale", Vector2(1.1, 1.1), 0.2).from(Vector2(1, 1))
					tween_m_i.tween_property(mycelium_grown_progress, "scale", Vector2(1, 1), 0.08)

			if mycelium_amount >= mycelium_target:
				track_mycelium = false
				get_tree().create_timer(1.2).timeout.connect(animation_player.play.bind("02_resource_panel"), CONNECT_ONE_SHOT)
				# hide bars
				var tween_m_hide: Tween = mycelium_grown_progress.create_tween()
				tween_m_hide.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
				tween_m_hide.tween_property(mycelium_grown_progress, "modulate:a", 0, 0.3).set_delay(0.3)

@onready var fade_hide: ColorRect = %fade_hide

func finish_tutorial():
	music_player.music.fade_out_ambient(1.8)

	var tween_fade: Tween = fade_hide.create_tween()
	tween_fade.tween_property(fade_hide, "modulate:a", 1.0, 2.0).from(0.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)

	await get_tree().create_timer(2.2).timeout

	Global.main.exit_tutorial(4)
