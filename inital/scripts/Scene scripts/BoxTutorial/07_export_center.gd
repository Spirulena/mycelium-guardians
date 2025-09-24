class_name TutorialExportCenter extends LevelView

var buildable: Dictionary
var tutorial_replay_component: TutorialReplayStepComponent
var camera_component: LevelCameraComponent
@onready var music_player: ViewComponent
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	buildable = {
		BuildingObject.StructureCategory.Emission: [BuildingObject.StructureType.Export_Center],
	}
	components_enable['HintsComponent'] = false
	components_enable['GroundPresenterComponent'] = true
	components_enable['TileDebugComponent'] = true
	components_enable['EnzymesComponent'] = false
	components_enable['SmogComponent'] = true
	components_enable['ChanceControllerComponent'] = true
	components_enable['MusicPlayerComponent'] = true # will trigger music in tutorial via animation or request

	level_controller.level_data._base_coords = [Vector2i(0,0)]
	level_controller.set_buildable(buildable)
	level_controller.level_data._tally[ResourceObject.ResourceType.Water] = [600, 600]
	level_controller.level_data._tally[ResourceObject.ResourceType.Energy] = [600, 600]
	level_controller.level_data._tally[ResourceObject.ResourceType.Minerals] = [600, 600]
	level_controller.level_data._tally[ResourceObject.ResourceType.Energy] = [600, 600]
	level_controller.level_data._tally[ResourceObject.ResourceType.Enzymes] = [200, 200]
	super()
	level_controller.set_ignore_water_noise(true)
	init_mycelium()

	# Hide UI elements
	game_ui_controller.hide_element('Overlay')
	game_ui_controller.hide_element('SideDebug')

	music_player = components.get("MusicPlayerComponent")
	# get camera
	camera_component = components.get("LevelCameraComponent")
	#camera_component.move_with_keys_enabled = false
	camera_component.camera2d.zoom = Vector2(1, 1)
	camera_component.camera2d.position = Vector2(0, 0)
	#camera_component.camera2d.limit_right = 7000
	#camera_component.camera2d.limit_bottom = 3000
	#camera_component.camera2d.limit_left = -9000
	#camera_component.camera2d.limit_top = -7000
	tutorial_replay_component = TutorialReplayStepComponent.new(level_controller, self, game_ui_controller, 'TutorialReplayStepComponent')
	add_child(tutorial_replay_component)
	tutorial_replay_component.setup(replay_instructions, exit_instructions)

	absorber_label.text = "Grow Exchange Center: %d/%d" % [absorber_amount, absorber_target]
	storage_label.text = "Grow Carbon Storage Collector: %d/%d" % [storage_amount, storage_target]

func init_mycelium():
	var mycelium_positions = [
		Vector2(0, 1), Vector2(1, 0), Vector2(1, 1), Vector2(1, 2), Vector2(2, 1), Vector2(2, -1),
		Vector2(2, 0), Vector2(2, 2), Vector2(2, 3), Vector2(1, -1), Vector2(1, -2), Vector2(0, -2),
		Vector2(0, -3), Vector2(-1, -3), Vector2(-1, -4), Vector2(-2, -4), Vector2(-2, -5),
		Vector2(-3, -5), Vector2(-3, -6), Vector2(-4, -6), Vector2(-4, -7), Vector2(-4, -5),
		Vector2(-4, -4), Vector2(-3, -7), Vector2(-2, -7), Vector2(-2, -6), Vector2(-1, -7)
		]
	#var mycelium_positions = [
		#Vector2(0, 1), Vector2(1, 0), Vector2(1, 1), Vector2(1, 2), Vector2(2, 1), Vector2(2, -1)]
	for coords in mycelium_positions:
		level_controller.add_object(MyceliumObject.new(coords))
		level_controller.get_tile_at(coords).set_discovered_in_radius(true, 4)

	for coords in mycelium_positions:
		var seed_mycelium = level_controller.get_tile_at(coords).get_mycelium()
		seed_mycelium.set_state(MyceliumObject.MyceliumState.Idle)
		seed_mycelium.set_health(100)

func preview_mycelium():
	start_click(Vector2i(2,1))
	for i in range(2, 15):
		await get_tree().create_timer(0.15).timeout
		move_press(Vector2i(i,1))

func exit_preview_mycelium():
	click_cancel()
	game_ui_controller.set_handle_events(false) # tmp disable mouse handling

# # move to some lib
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
# move to some lib

# 01
func replay_instructions():
	tutorial_replay_component.hide_replay_window()
	animation_player.play("01")

@onready var _01: Label = $"CanvasLayer/Instructions/01"
func exit_instructions():
	tutorial_replay_component.hide_replay_window()
	tutorial_replay_component.setup(replay_rad_storage, exit_rad_storage)

@onready var _02: Label = %"02"
func replay_rad_storage():
	tutorial_replay_component.hide_replay_window()
	animation_player.play("02")

func exit_rad_storage():
	tutorial_replay_component.hide_replay_window()
	tutorial_replay_component.setup(replay_summary, exit_summary)

func replay_summary():
	pass

var clicked: bool = false
@onready var _03: Label = %"03"
func exit_summary():
	if not clicked:
		clicked = true
		finish_tutorial()

# shoudl this be a part of tutorial component
func show_tutorial_replay_window():
	tutorial_replay_component.show_replay_window()

var storage_target: int = 1
var storage_amount: int = 0

var absorber_target: int = 1
var absorber_amount: int = 0

@onready var absorber_progress: TextureProgressBar = %AbsorberProgress
@onready var absorber_label: Label = %AbsorberLabel

@onready var storage_progress: TextureProgressBar = %StorageProgress
@onready var storage_label: Label = %StorageLabel

@onready var _04: Label = %"04"

var tracking_absorber: bool = true

func fill_tiles(coords, radius):
	var tiles_coords: = level_controller.get_coords_in_circle(coords, radius)
	var resources = [ResourceObject.ResourceType.Water, ResourceObject.ResourceType.Minerals]

	for coord in tiles_coords:
		var tile: TileObject = level_controller.get_tile_at(coord)
		for resource in resources:
			tile.set_tally(resource, 10)

var absorbers_done: bool = false
var pass_change: bool = true
func  _on_view_changed(change: Dictionary):
	pass_change = true

	if change.type == GUIController.Actions.GrowStructure and change.state == 'place_request':
		if change.building_id == BuildingObject.StructureType.Export_Center:
			if absorber_amount >= absorber_target:
				pass_change = false
				print_debug("Enough Absorbers")
				# do cancel
				game_ui_controller.view_changed.emit.call_deferred({
					'type': GUIController.Actions.GrowStructure,
					'state': 'place_not_allowed',
					'coords': change.coords,
					'instance': change.instance,
				})
		else:
			pass_change = true
	else:
		pass_change = true

	if pass_change:
		super._on_view_changed(change)


func _on_model_changed(change: Dictionary):
	super._on_model_changed(change)

	# capture storage structure grown
	if change.type == ModelObject.Type.Building:
		if change.prev == null:
			pass # count

			var model: BuildingObject = change.curr
			var id = model.get_building_type()
			if id == BuildingObject.StructureType.Export_Center:
				if not tracking_absorber:
					return
				absorber_amount += 1
				# do the scale tweens
				if absorber_amount == 1:
					var tween_s_i: Tween = _01.create_tween()
					tween_s_i.tween_property(_01, "modulate:a", 0.0, 2.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)

				if absorber_amount > 0:
					absorber_progress.value = storage_amount
					absorber_label.text = "Grow Exchange Center: %d/%d" % [absorber_amount, absorber_target]
					# can scale up after each one
					var tween_i: Tween = absorber_progress.create_tween()
					tween_i.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
					tween_i.tween_property(absorber_progress, "scale", Vector2(1.2, 1.2), 0.3)
					tween_i.tween_property(absorber_progress, "scale", Vector2(1, 1), 0.1)

				if absorber_amount >= absorber_target:
					# fade out
					# tween, scale the indicator, then fade out
					var tween: Tween = absorber_progress.create_tween()
					tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
					tween.tween_property(absorber_progress, "modulate:a", 0, 0.3).set_delay(0.3)
					# Show text to wait ?
					model.state_changed.connect(_on_absorber_state_changed)

					var tween_message: Tween = _04.create_tween()
					tween_message.tween_property(_04, "modulate:a", 1, 2).from(0.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
					tracking_absorber = false

					## fill in the water, minerals to sustain export
					var limit = level_controller.get_tally_storage_limit(ResourceObject.ResourceType.Carbon)
					level_controller.level_data.set_tally(ResourceObject.ResourceType.Carbon, limit)
					fill_tiles(model.get_coords(), 1)

func _on_absorber_state_changed(change: Dictionary):
	if change.prop == 'state' and change.curr == BuildingObject.BuildingState.Done:
		absorbers_done = true
		finish_tutorial()

@onready var fade_hide: ColorRect = %fade_hide
func finish_tutorial():
	await get_tree().create_timer(1).timeout
	music_player.music.fade_out_ambient(1.8)

	var tween_fade: Tween = fade_hide.create_tween()
	tween_fade.tween_property(fade_hide, "modulate:a", 1.0, 2.0).from(0.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)

	await get_tree().create_timer(2.2).timeout

	Global.main.exit_tutorial(7)
