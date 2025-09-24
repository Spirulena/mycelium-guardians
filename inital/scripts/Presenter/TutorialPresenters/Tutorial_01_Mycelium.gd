class_name TutorialMycelium extends LevelView

# load whats needed
# init data
var tutorial_replay_component: TutorialReplayStepComponent
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var preface: AnimationPlayer = $preface

@onready var music_player: ViewComponent

@onready var ruins_reference: ViewComponent
@export var ruins_alpha: float = 0.0

var ruins_amount: int = 3
var ruins_connected_amount: int = 0
var ruins_connected_target: int = 3
var ruins_decompose_amount: int = 0
var ruins_decompose_target: int = 3

func _ready() -> void:
	components_enable['HintsComponent'] = false
	components_enable['GroundPresenterComponent'] = false
	components_enable['TileDebugComponent'] = true
	components_enable['EnzymesComponent'] = true
	components_enable['SmogComponent'] = false
	components_enable['ChanceControllerComponent'] = false
	components_enable['MusicPlayerComponent'] = true # will trigger music in tutorial via animation or request
	components_enable['LevelCameraComponent'] = false
	# TODO: Block tmp mouse actions, and any mouse events
	#
	super()
	level_controller.level_data._base_coords = [Vector2i(-1, -1)]
	# Filter out changes we want to ignore. or clear all and add what we want
	add_component_view_ignore('OverlaysViewComponent', ['Overlay', GUIController.Actions.GrowStructure, GUIController.Actions.Explore])

	# Hide elements we don't want
	# game_ui_controller.hide_element("MapGUI")
	# Hide UI elements
	game_ui_controller.hide_element('Overlay')
	game_ui_controller.hide_element('ResourcesPanel')
	game_ui_controller.hide_element('SideDebug')
	game_ui_controller.hide_element('BottomMenu')
	game_ui_controller.hide_element('ZoomUI')
	# TODO: Hide zoom controls

	game_ui_controller.set_handle_events(false) # tmp disable mouse handling
	game_ui_controller.ignore_view_change_type.append(GUIController.Actions.Explore)
	#init_level()

	tutorial_replay_component = TutorialReplayStepComponent.new(level_controller, self, game_ui_controller, 'TutorialReplayStepComponent')
	add_child(tutorial_replay_component)
	tutorial_replay_component.setup(replay_call, exit_call)
	preface.play("preface")
	preface.animation_finished.connect(func(anim): animation_player.play("00_cancel"))

	ruins_reference = components.get("RuinComponent")
	music_player = components.get("MusicPlayerComponent")

func preface_mycelium():
	var mycelium_positions = [Vector2i(-1, -1)]
	for coords in mycelium_positions:
		level_controller.add_object(MyceliumObject.new(coords))
		level_controller.get_tile_at(coords).set_discovered_in_radius(true, 5)

	var seed_mycelium = level_controller.get_tile_at(Vector2i(-1, -1)).get_mycelium()
	seed_mycelium.set_state(MyceliumObject.MyceliumState.Idle)
	seed_mycelium.set_health(100)

func rest_of_mycelium():
	var mycelium_positions = [Vector2i(0, -1), Vector2i.ZERO]
	for coords in mycelium_positions:
		level_controller.add_object(MyceliumObject.new(coords))
		level_controller.get_tile_at(coords).set_discovered_in_radius(true, 5)

func init_ruins():
	ruins_reference.modulate.a = 0.0

	#var resources: Array[ResourceObject] = []

	var coords = Vector2i(0, 4)
	var resources: Array[ResourceObject] = [ResourceObject.new(coords, ResourceObject.ResourceType.Carbon, 2)]
	for resource in resources:
		level_controller.add_resource(resource)
	level_controller.add_object(RuinObject.new(coords, Vector2i(1, 1), 'ruin_log_01', resources))

	coords = Vector2i(-4,-4)
	var resources2:  Array[ResourceObject] = [ResourceObject.new(coords, ResourceObject.ResourceType.Carbon, 2)]
	for resource in resources2:
		level_controller.add_resource(resource)
	level_controller.add_object(RuinObject.new(coords, Vector2i(1, 1), 'ruin_log_02', resources2))

	coords = Vector2i(5, 0)
	var resources3:  Array[ResourceObject] = [ResourceObject.new(coords, ResourceObject.ResourceType.Carbon, 2)]
	for resource in resources3:
		level_controller.add_resource(resource)
	level_controller.add_object(RuinObject.new(coords, Vector2i(1, 1), 'ruin_log_01', resources3))

	var tween: Tween = self.create_tween()
	tween.tween_property(ruins_reference, "modulate:a", 1.0, 1.0).from(0.0)

func clear_ruins():
	var ruins_coords = [Vector2i(0, 4), Vector2i(-5,-5), Vector2i(5, 0)]
	for coords in ruins_coords:
		var ruin = level_controller.get_tile_at(coords).get_ruin()
		level_controller.remove_object(ruin)

func init_level():
	var mycelium_positions = [Vector2i(-1, -1), Vector2i(0, -1), Vector2i.ZERO]
	for coords in mycelium_positions:
		level_controller.add_object(MyceliumObject.new(coords))
		level_controller.get_tile_at(coords).set_discovered_in_radius(true, 5)

	var seed_mycelium = level_controller.get_tile_at(Vector2i.ZERO).get_mycelium()
	seed_mycelium.set_state(MyceliumObject.MyceliumState.Idle)
	seed_mycelium.set_health(100)

	# Tank Ruin
	var coords = Vector2i(-3, -3)
	var resources: Array[ResourceObject] = [ResourceObject.new(coords, ResourceObject.ResourceType.Minerals, 200)]
	for resource in resources:
		level_controller.add_resource(resource)
	level_controller.add_object(RuinObject.new(coords, Vector2i(1, 2), 'ruin_tank_02', resources,))

func start_click():
	var curr_action = GUIController.Actions.Explore
	game_ui_controller.set_current_action_mode(curr_action)
	game_ui_controller._mouse_controller._state_handlers[curr_action].handle_press(Vector2i(0,0))

func move_press(y: int):
	var curr_action = GUIController.Actions.Explore
	var coords = Vector2i(0, y)
	game_ui_controller._mouse_controller._state_handlers[curr_action].handle_move(coords)

func click_release(y: int):
	var curr_action = GUIController.Actions.Explore
	var coords = Vector2i(0, y)
	game_ui_controller._mouse_controller._state_handlers[curr_action].handle_release(coords)

func click_cancel():
	var curr_action = GUIController.Actions.Explore
	game_ui_controller.set_selected(null)
	game_ui_controller._mouse_controller._state_handlers[curr_action].reset()

func show_tutorial_replay_window():
	print_debug("Show tutorial replay window")
	game_ui_controller.view_changed.emit({
		'type': 'tutorial',
		'prop': 'show_window',
		'curr': 'replay_window',
		'prev': null,
	})

func replay_call():
	print_debug("Replay call")
	#  hide window
	game_ui_controller.view_changed.emit({
		'type': 'tutorial',
		'prop': 'hide_window',
		'curr': 'replay_window',
		'prev': null,
	})
	clear_drawn_mycelium()
	animation_player.play("00_cancel")

func exit_call():
	print_debug("Exit call")
	game_ui_controller.view_changed.emit({
		'type': 'tutorial',
		'prop': 'hide_window',
		'curr': 'replay_window',
		'prev': null,
	})
	game_ui_controller.set_handle_events(true) # re-enable mouse handling
	# reset selection and handler
	game_ui_controller.set_current_action_mode(game_ui_controller.default_action)
	game_ui_controller.set_selected(null)

	#game_ui_controller._mouse_controller.set_selected(null)
	#var curr_action = GUIController.Actions.Explore
	#if game_ui_controller._mouse_controller._state_handlers.has(curr_action):
		#game_ui_controller._mouse_controller._state_handlers[curr_action].reset()
	# Now capture goal achivement.
	# Grow over tanks
	# Show task status

func clear_drawn_mycelium():
	# mute prune sounds
	for y in range(1, 5):
		var coords = Vector2i(0, y)
		var mycelium = level_controller.get_tile_at(coords).get_mycelium()
		level_controller.remove_object(mycelium)

# Preface instructions with animated text,

# This is mycelium 							# show arrows pointing at mycelium tiles
# Thread like branching fungal body 		# add icons for each word, optional
# Ever expanding network

# Animation should expand towards ruin, and the number of ruins connected in goal should increase

# Also when playing instructions
# Left click and drag from any mycelium tile
# To preview expansion path
# Release Left Click to expand the network
# or Right Click to cancel					# Also show in visual instruction ?

# listen to view for connected ruins
#func _on_view_changed(change: Dictionary) -> void:
	#super._on_view_changed(change)

@onready var ruins_decomposed_label: Label = %RuinsDecomposedLabel
@onready var decomposed_progress: TextureProgressBar = %DecomposedProgress
@onready var connected_progress: TextureProgressBar = %ConnectedProgress

var ruins_connected: Dictionary = {}

func _on_model_changed(change: Dictionary):
	super._on_model_changed(change)

	# TODO: capture connections
	if change.type == 'ConnectionToBase':
		if change.object.get_type() == ModelObject.Type.Ruin and change.prev == true and change.curr == false:
			ruins_connected_amount -= 1
		if change.object.get_type() == ModelObject.Type.Ruin and change.prev == false and change.curr == true:
			# What to do when disconnecting when replaying animation ?
			print_debug("Ruin connected")
			ruins_connected_amount += 1
			connected_progress.value = ruins_connected_amount
			if ruins_connected_amount == ruins_connected_target:
				# tween, scale the indicator, then fade out
				var tween: Tween = connected_progress.create_tween()
				tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
				tween.tween_property(connected_progress, "scale", Vector2(1.2, 1.2), 0.3)
				tween.tween_property(connected_progress, "scale", Vector2(1, 1), 0.2)
				tween.tween_property(connected_progress, "modulate:a", 0, 0.3)

	if change.type == ModelObject.Type.Ruin:
		if change.curr == null:
			print_debug("Tutorial: ruin gone", change)
			ruins_decompose_amount += 1
			ruins_decomposed_label.text = "Goal - Decompose: %d/%d" % [ruins_decompose_amount, ruins_decompose_target]
			decomposed_progress.value = ruins_decompose_amount
			# Also show on map the ruin that got decomposed
			if ruins_decompose_amount == ruins_decompose_target:
				# tween, scale the indicator, then fade out
				var tween: Tween = decomposed_progress.create_tween()
				tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
				tween.tween_property(decomposed_progress, "scale", Vector2(1.2, 1.2), 0.3)
				tween.tween_property(decomposed_progress, "scale", Vector2(1, 1), 0.2)
				tween.tween_property(decomposed_progress, "modulate:a", 0, 0.3)
				print_debug("Done with decomposing")
				# TODO: add sfx, mushroom piniata
				finish_tutorial()

@onready var fade_out_rect: ColorRect = %FadeOutRect
@onready var text_intruction: Label = %Text_Intruction
func finish_tutorial():
	music_player.music.fade_out_ambient(2.0)
	var tween: Tween = text_intruction.create_tween()
	tween.tween_property(text_intruction, "modulate:a", 0.0, 2.0).from(1.0)

	var tween_fade: Tween = fade_out_rect.create_tween()
	tween_fade.tween_property(fade_out_rect, "modulate:a", 1.0, 2.0).from(0.0)

	# Fade out, give some feedback
	# Fade out noise
	await get_tree().create_timer(2).timeout
	Global.main.exit_tutorial(1)
