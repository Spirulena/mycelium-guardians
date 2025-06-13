class_name TutorialEnzymes extends LevelView

var buildable: Dictionary
var tutorial_replay_component: TutorialReplayStepComponent
var camera_component: LevelCameraComponent
@onready var music_player: ViewComponent
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:

	components_enable['HintsComponent'] = false
	components_enable['GroundPresenterComponent'] = true
	components_enable['TileDebugComponent'] = false
	components_enable['EnzymesComponent'] = true
	components_enable['SmogComponent'] = true
	components_enable['ChanceControllerComponent'] = true
	components_enable['MusicPlayerComponent'] = true # will trigger music in tutorial via animation or request

	level_controller.level_data._base_coords = [Vector2i(0,0)]
	level_controller.set_buildable(buildable)
	level_controller.level_data._tally[ResourceObject.ResourceType.Water] = [600, 600]
	level_controller.level_data._tally[ResourceObject.ResourceType.Energy] = [600, 600]
	level_controller.level_data._tally[ResourceObject.ResourceType.Minerals] = [600, 600]
	level_controller.level_data._tally[ResourceObject.ResourceType.Energy] = [600, 600]
	level_controller.level_data._tally[ResourceObject.ResourceType.Enzymes] = [30, 100]
	super()
	level_controller.set_ignore_water_noise(false)
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

# 01
func replay_instructions():
	tutorial_replay_component.hide_replay_window()
	animation_player.play("01")

@onready var _01: Label = $"CanvasLayer/Instructions/01"
func exit_instructions():
	tutorial_replay_component.hide_replay_window()
	tutorial_replay_component.setup(replay_summary, exit_summary)

func replay_summary():
	pass

var clicked: bool = false
func exit_summary():
	if not clicked:
		clicked = true
		finish_tutorial()

# shoudl this be a part of tutorial component
func show_tutorial_replay_window():
	tutorial_replay_component.show_replay_window()

@onready var fade_hide: ColorRect = %fade_hide
func finish_tutorial():
	await get_tree().create_timer(1).timeout
	music_player.music.fade_out_ambient(1.8)

	var tween_fade: Tween = fade_hide.create_tween()
	tween_fade.tween_property(fade_hide, "modulate:a", 1.0, 2.0).from(0.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)

	await get_tree().create_timer(2.2).timeout

	Global.main.exit_tutorial(8)

var monitoring_enzymes_panel: bool = true

func _on_view_changed(change: Dictionary):
	super._on_view_changed(change)

	if change.type == 'enzymes' and change.prop == 'button_pressed':
		if change.curr == true and change.prev != true:
			pass
			if monitoring_enzymes_panel:
				monitoring_enzymes_panel = false
				tutorial_replay_component.hide_replay_window()
				tutorial_replay_component.setup(replay_summary, exit_summary)
				animation_player.play("02")
