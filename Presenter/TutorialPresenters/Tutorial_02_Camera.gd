class_name TutorialCamera extends LevelView

# load whats needed
# init data
var tutorial_replay_component: TutorialReplayStepComponent

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var preface: AnimationPlayer = $preface

@onready var music_player: ViewComponent
@onready var camera_component: LevelCameraComponent

func _ready() -> void:
	components_enable['HintsComponent'] = false
	components_enable['GroundPresenterComponent'] = false
	components_enable['TileDebugComponent'] = true
	components_enable['EnzymesComponent'] = true
	components_enable['SmogComponent'] = false
	components_enable['ChanceControllerComponent'] = false
	components_enable['MusicPlayerComponent'] = true # will trigger music in tutorial via animation or request

	# Enable camera but ingore changes until introduced by instructions
	components_enable['LevelCameraComponent'] = true

	super()
	level_controller.level_data._base_coords = [Vector2i(-1, -1)]

	# Filter out changes we want to ignore. or clear all and add what we want
	add_component_view_ignore('OverlaysViewComponent', ['Overlay', GUIController.Actions.GrowStructure, GUIController.Actions.Explore])
	#
	add_component_view_ignore('LevelCameraComponent', ['Zoom', 'MouseDrag'])

	# Hide elements we don't want
	# game_ui_controller.hide_element("MapGUI")
	# Hide UI elements
	game_ui_controller.hide_element('Overlay')
	game_ui_controller.hide_element('ResourcesPanel')
	game_ui_controller.hide_element('SideDebug')
	game_ui_controller.hide_element('BottomMenu')
	game_ui_controller.hide_element('ZoomUI')

	# Show zoom controls after introducing zoom
	# TODO: Hide zoom controls

	# Ignore zoom

	#game_ui_controller.set_handle_events(false) # tmp disable mouse handling
	#game_ui_controller.ignore_view_change_type.append(GUIController.Actions.Explore)
	#init_level()

	tutorial_replay_component = TutorialReplayStepComponent.new(level_controller, self, game_ui_controller, 'TutorialReplayStepComponent')
	add_child(tutorial_replay_component)
	tutorial_replay_component.setup(replay_call, exit_call)

	preface.play("preface")
	preface.animation_finished.connect(func(anim): animation_player.play("01"))
	animation_player.animation_finished.connect(func(anim): if anim == "01": animation_player.play("show_zoom_ui"))

	music_player = components.get("MusicPlayerComponent")
	camera_component = components.get("LevelCameraComponent")
	camera_component.move_with_keys_enabled = false
	camera_component.camera2d.zoom = Vector2(0.8, 0.8)
	camera_component.camera2d.position = Vector2(0, 0)
	camera_component.camera2d.limit_right = 7000
	camera_component.camera2d.limit_bottom = 3000
	camera_component.camera2d.limit_left = -9000
	camera_component.camera2d.limit_top = -7000
	#music_player.music.fade_out_ambient(2.0)
	# fade out, stop ambient, then reset volume

	# simulate finishing level 2
	#await get_tree().create_timer(10).timeout
	#Global.main.exit_tutorial(2)
	AudioServer.set_bus_mute(AudioServer.get_bus_index("ff_crasher"), false)
	#add_ff_crushers()
	level_controller.get_tile_at(Vector2i(13, 4)).set_discovered_in_radius(true, 10)
	level_controller.add_movable(CreatureObject.new(Vector2i(12, -2), CreatureObject.CreatureType.FFCrasher))
	level_controller.add_movable(CreatureObject.new(Vector2i(15, 5), CreatureObject.CreatureType.FFCrasher))

	init_mycelium()

func add_ff_crushers():
	level_controller.get_tile_at(Vector2i(13, 4)).set_discovered_in_radius(true, 10)
	level_controller.add_movable(CreatureObject.new(Vector2i(12, -2), CreatureObject.CreatureType.FFCrasher))
	level_controller.add_movable(CreatureObject.new(Vector2i(15, 5), CreatureObject.CreatureType.FFCrasher))

func init_mycelium():
	var mycelium_positions = [Vector2i(-1, 11), ]
	for i in range(0, 11):
		mycelium_positions.append(Vector2i(-1, i))

	for coords in mycelium_positions:
		level_controller.add_object(MyceliumObject.new(coords))
		level_controller.get_tile_at(coords).set_discovered_in_radius(true, 5)

	#var seed_mycelium = level_controller.get_tile_at(mycelium_positions[0]).get_mycelium()
	#seed_mycelium.set_state(MyceliumObject.MyceliumState.Idle)
	#seed_mycelium.set_health(100)

	for coords in mycelium_positions:
		var seed_mycelium = level_controller.get_tile_at(coords).get_mycelium()
		seed_mycelium.set_state(MyceliumObject.MyceliumState.Idle)
		seed_mycelium.set_health(100)

func show_zoom_ui():
	game_ui_controller.show_element('ZoomUI')

func enable_zoom():
	del_component_view_ignore('LevelCameraComponent', ['Zoom',])

func enable_move_camera():
	del_component_view_ignore('LevelCameraComponent', ['MouseDrag',])
	camera_component.move_with_keys_enabled = true

func show_tutorial_replay_window():
	print_debug("Show tutorial replay window")
	game_ui_controller.view_changed.emit({
		'type': 'tutorial',
		'prop': 'show_window',
		'curr': 'replay_window',
		'prev': null,
	})

func replay_call_drag():
	print_debug("Replay call")
	#  hide window
	game_ui_controller.view_changed.emit({
		'type': 'tutorial',
		'prop': 'hide_window',
		'curr': 'replay_window',
		'prev': null,
	})

	animation_player.play("drag")

func exit_call_drag():
	#print_debug("Exit call")
	game_ui_controller.view_changed.emit({
		'type': 'tutorial',
		'prop': 'hide_window',
		'curr': 'replay_window',
		'prev': null,
	})

	# move to next level
	finish_tutorial()

@onready var fade_out_rect: ColorRect = %FadeOutRect
#@onready var text_intruction: Label = %Text_Intruction
func finish_tutorial():
	music_player.music.fade_out_ambient(1.8)
	#var tween: Tween = text_intruction.create_tween()
	#tween.tween_property(text_intruction, "modulate:a", 0.0, 2.0).from(1.0)

	var tween_fade: Tween = fade_out_rect.create_tween()
	tween_fade.tween_property(fade_out_rect, "modulate:a", 1.0, 2.0).from(0.0)

	# Fade out, give some feedback
	# Fade out noise
	await get_tree().create_timer(2.2).timeout

	Global.main.exit_tutorial(2)

func replay_call():
	print_debug("Replay call")
	#  hide window
	game_ui_controller.view_changed.emit({
		'type': 'tutorial',
		'prop': 'hide_window',
		'curr': 'replay_window',
		'prev': null,
	})

	animation_player.play("01")

func exit_call():
	print_debug("Exit call")
	game_ui_controller.view_changed.emit({
		'type': 'tutorial',
		'prop': 'hide_window',
		'curr': 'replay_window',
		'prev': null,
	})

	tutorial_replay_component.setup(replay_call_drag, exit_call_drag)
	animation_player.play("drag")

	#game_ui_controller.set_handle_events(true) # re-enable mouse handling
	## reset selection and handler
	#game_ui_controller.set_current_action_mode(game_ui_controller.default_action)
	#game_ui_controller.set_selected(null)
	# change replay to new, focused on drag ?
	#tutorial_replay_component = TutorialReplayStepComponent.new(level_controller, self, game_ui_controller, 'TutorialReplayStepComponent')
	#add_child(tutorial_replay_component)


# track changes
# zoom in first on mycelium
# track does it reaches zoom max,
	#if (change.type == 'Zoom'):
		#if change.curr == "reset":
			#zoom_reset_requested()
		#elif change.curr == "in":

# then zoom out
# gain perspective
# give sounds when reaches level
# also progress bar or height indicator
# might add juice later and do something simple now

# then enable mouse drag, middle click, or alt left click,

# then enable move with keys, wsad
# do not check, just give some time

# ask to find some object ?
# something interesing happening, tanks, FFcrasher comming, and some AGI structures around the forest ?
# to scare them

# then next tutorial can be green planet, blasts, then pink planet

# then next is placing collectors to get water, add more water to tally to not wait for it,

# place radiation to get energy, maybe place collector next to it, to get more storage

# place smog to get minerals,

# in exchange hub, prepopulate with energy, smog absorbers and collectors next to it.

# exchange hub to export resources, and carbon to collect carbon
# block increasing radius.
# or fix and allow placing carbon collector on grass, by removing grass
