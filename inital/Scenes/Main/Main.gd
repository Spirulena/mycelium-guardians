class_name Main extends Node2D

var level_controller

@onready var main_menu: MainMenu = $CanvasLayer/MainMenu
@onready var loaded_level: Array
@onready var tutorial_selection_screen: Control = $CanvasLayer/TutorialSelectionScreen
@onready var back_from_tutorial: Button = $CanvasLayer/TutorialSelectionScreen/back_from_tutorial
@onready var back_from_sandbox: Button = %back_from_sandbox
@onready var enter_sandbox: Button = %enter_sandbox
@onready var sandbox_options_screen: Control = $CanvasLayer/SandboxOptionsScreen
@onready var seed_value: LineEdit = %SeedValue
@onready var randomize_seed_texture_button: TextureButton = %RandomizeSeedTextureButton
@onready var randomize_seed_button: Button = %RandomizeSeedButton
@onready var pause_menu: Control = %PauseMenu
@onready var help_menu: Control = %HelpMenu

@export_category("Elements")
@export var elements_options_menu: Control
@export var elements_back: Button
@export var elements_enter: Button

signal main_view_changed
@export_category("Prologue Data")
@export var prologue_meta_list: Array[PrologueLevelMetaData]

func _init() -> void:
	loaded_level = []

func _ready():
	Global.main = self
	Loader.get_loader().load_all_from_path()
	# Signals
	main_menu.start_button_pressed.connect(_on_start_button_pressed)
	main_menu.sandbox_button_pressed.connect(_on_sandbox_button_pressed)
	main_menu.journey_button_pressed.connect(_on_journey_button_pressed)
	main_menu.elements_button_pressed.connect(_on_elements_button_pressed)
	main_menu.tutorial_button_pressed.connect(_on_tutorial_button_pressed)

	# TODO: Need a way to have load_level load data according to what level needs
	main_menu.debug_button_pressed.connect(func(): add_level_skeleton("level_test_empty"))

	main_menu.help_button_pressed.connect(help_button_pressed)
	back_from_tutorial.pressed.connect(_on_back_from_tutorial_pressed)

	# sandbox buttons
	back_from_sandbox.pressed.connect(_on_back_from_sandbox_pressed)
	enter_sandbox.pressed.connect(_on_enter_sandbox_pressed)
	randomize_seed_button.pressed.connect(_on_randomize_seed_button_pressed)

	# Elements buttons
	elements_back.pressed.connect(_on_elements_back_pressed)
	elements_enter.pressed.connect(_on_elements_enter_pressed)

	# init visibility
	main_menu.show()
	tutorial_selection_screen.hide()
	sandbox_options_screen.hide()
	elements_options_menu.hide()


	# Enable all buttons for testing
	# connect button pressed to action
	for meta in prologue_meta_list:
		var button: Button = get_node(meta.button)
		button.disabled = false
		button.pressed.connect(_on_tutorial_n_pressed.bind(meta))
	#for data_key in tutorial_data.keys():
		#tutorial_data[data_key].button.pressed.connect(_on_tutorial_n_pressed.bind(data_key))

	_on_randomize_seed_button_pressed()
	main_view_changed.connect(_on_main_view_changed)

# Elements funcs
func _on_elements_button_pressed():
	tween_hide_main_menu()
	tween_show_elements_menu()

func _on_elements_back_pressed():
	tween_hide_elements_menu()
	tween_show_main_menu()

func _on_elements_enter_pressed():
	tween_hide_elements_menu()
	# For now just one elements level, no need to check if was selected
	print_debug("Elements button pressed")
	# TODO: add Element selector, more like prologue logic
	add_level_skeleton("elements_01", "elements_01".hash()) #have way to define resources in map

func _on_randomize_seed_button_pressed():
	var seed_string = generate_random_string(16)
	seed_value.text = seed_string

func _on_sandbox_button_pressed():
	# add seed input window
	tween_hide_main_menu()
	tween_show_sandbox_menu()

func _on_journey_button_pressed():
	print_debug("Journey button pressed")
	# TODO: add journey submenu, select level or continue save.
	add_level_skeleton("journey_01", "journey01".hash()) #have way to define resources in map

func _on_back_from_sandbox_pressed():
	tween_hide_sandbox_menu()
	tween_show_main_menu()

func _on_enter_sandbox_pressed():
	tween_hide_sandbox_menu()
	var seed_hash = seed_value.text.hash()
	add_level_skeleton("level_01", seed_hash) # this is just the scene with containers and tile maps
	var _lc = LevelController.get_level_controller()

func _on_start_button_pressed():
	add_level_skeleton("level_01") # this is just the scene with containers and tile maps

func help_button_pressed():
	# when gui loaded, show help screen
	# when in main menu, here, show help screen
	# TODO: we do not have screens controller, here
	print("show help screen")

func _on_back_from_tutorial_pressed():
	tween_show_main_menu()
	tween_hide_tutorial_selection_menu()

func _on_tutorial_button_pressed():
	tween_hide_main_menu()
	tween_show_tutorial_menu()

var tutorial_selected: bool = false
var current_meta: PrologueLevelMetaData
func _on_tutorial_n_pressed(meta: PrologueLevelMetaData):
	if tutorial_selected:
		return
	tutorial_selected = true
	#print_debug("Tutorial Key: ", key)
	tween_hide_tutorial_selection_menu()

	# TODO: check for null
	var level_key = meta.scene_key
	add_level_skeleton(level_key)
	current_meta = meta

# keep which one was selected ? and loaded, and just get next in list
func exit_tutorial(number: int):
	var current: = prologue_meta_list.find(current_meta) # index or -1 if none
	var next_i = current + 1
	var next_key = "invalid"
	if prologue_meta_list[next_i] != null:
		prologue_meta_list[next_i].enable = true
		next_key = prologue_meta_list[next_i].scene_key
		get_node(prologue_meta_list[next_i].button).disabled = false
		current_meta = prologue_meta_list[next_i]

	clear_level()
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	add_level_skeleton(next_key)

func clear_level():
	for this_level in loaded_level:
		this_level.queue_free()
	loaded_level.clear()
	get_tree().paused = false

func back_to_main():
	clear_level()
	tween_show_main_menu()
	get_tree().paused = false

# TODO: add state machine to manage Game states, UI states
func add_level_skeleton(level_key, seed_string = null):
	var level = Loader.get_loader().return_scene(level_key).instantiate()
	if seed_string != null:
		LevelController.get_level_controller().update_seed(seed_string)
	add_child(level)
	loaded_level.append(level)
	main_menu.hide()

func pause_game():
	get_tree().paused = true
	pause_menu.show()

func un_pause_game():
	get_tree().paused = false

func _on_main_view_changed(change: Dictionary) -> void:
		# Help Screen
	if change.type == 'ResumeGame' and change.screen == 'PauseMenu':
		# mitigate to Game
		pause_menu.hide()
		un_pause_game()
	elif change.type == 'PauseGame' and change.screen == 'PauseMenu':
		if change.curr == true:
			if self.visible:
				# ignore
				return
			pause_game()

		#'type': 'ShowScreen',
		#'screen': 'MainMenu',
		#'prev': false,
		#'curr': true,
	elif change.type == 'ShowScreen' and change.screen == 'MainMenu':
		# go back to main menu
		print_debug("going back to main, will clear level")
		Global.main.back_to_main()
		pause_menu.hide()

	# move to Global.main ?
	elif change.type == 'ShowScreen' and change.screen == 'HelpMenu':
		if change.curr == true:
			pause_menu.hide()
			help_menu.show()
		elif change.curr == false:
			pause_menu.show()
			help_menu.hide()

var level_gui_visible:bool = true
func _unhandled_input(event: InputEvent) -> void:
	# if editor
	if event.is_action_pressed("editor_hide_gui") and OS.has_feature("editor"):
		main_view_changed.emit({
			'type': 'LevelGUI',
			'curr': !level_gui_visible,
			'prev': level_gui_visible
		})
		level_gui_visible = !level_gui_visible
		# hide, progress bars of decay,
		# hide, Elements -> temp canvas
		# hide ruins progress bars
		# selection cursor, iso square
	if event.is_action_pressed("editor_capture_screenshot") and OS.has_feature("editor"):
		await RenderingServer.frame_post_draw
		var capture = get_viewport().get_texture().get_image()
		var _time = Time.get_datetime_string_from_system()
		#var filename = "res://screenshots/screenshot-{0}.png".format({"0":_time})
		var filename_user = "user://screenshot-{0}.png".format({"0":_time})
		#capture.save_png(filename)
		capture.save_png(filename_user)

	if event.is_action_pressed("pause_level"):
		get_tree().paused = !get_tree().paused
	return
	if event.is_action_pressed("game_ui_esc"):
		#var change = {
			#'type': 'PauseGame',
			#'screen': 'PauseMenu',
			#'prev': true,
			#'curr': false,
		#}
		#main_view_changed.emit(change)
		#if help_menu.visible:
			#help_menu.hide()
			#pause_menu.show()
		if main_menu.visible or sandbox_options_screen.visible or tutorial_selection_screen.visible or help_menu.visible:
			return
		# if sandbox_options_screen.visible do back
		# if tutorial_selection_screen.visible do back
		# pass ESC to GUI ?
		else:
			pause_game()

func tween_show_main_menu():
	main_menu.show()
	var tween_show_main_menu: Tween = main_menu.create_tween()
	tween_show_main_menu.tween_property(main_menu, "modulate:a", 1.0, 0.8).from(0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)

func tween_show_tutorial_menu():
	tutorial_selected = false
	tutorial_selection_screen.show()
	var tween_show_tutorial_menu: Tween = tutorial_selection_screen.create_tween()
	tween_show_tutorial_menu.tween_property(tutorial_selection_screen, "modulate:a", 1.0, 0.8).from(0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)

func tween_show_sandbox_menu():
	sandbox_options_screen.show()
	var tween_a1: Tween = sandbox_options_screen.create_tween()
	tween_a1.tween_property(sandbox_options_screen, "modulate:a", 1.0, 0.8).from(0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)

func tween_show_elements_menu():
	elements_options_menu.show()
	var tween_a1: Tween = elements_options_menu.create_tween()
	tween_a1.tween_property(elements_options_menu, "modulate:a", 1.0, 0.8).from(0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)

func tween_hide_main_menu():
	var tween_hide_main_menu: Tween = main_menu.create_tween()
	tween_hide_main_menu.tween_property(main_menu, "modulate:a", 0.0, 0.8).from(1.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween_hide_main_menu.tween_callback(main_menu.hide)

func tween_hide_tutorial_selection_menu():
	var tween_hide_tutorial: Tween = tutorial_selection_screen.create_tween()
	tween_hide_tutorial.tween_property(tutorial_selection_screen, "modulate:a", 0.0, 0.8).from(1.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween_hide_tutorial.tween_callback(tutorial_selection_screen.hide)

func tween_hide_elements_menu():
	var tween_hide_elements: Tween = elements_options_menu.create_tween()
	tween_hide_elements.tween_property(elements_options_menu, "modulate:a", 0.0, 0.8).from(1.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween_hide_elements.tween_callback(elements_options_menu.hide)

func tween_hide_sandbox_menu():
	var tween_hide_sandbox: Tween = sandbox_options_screen.create_tween()
	tween_hide_sandbox.tween_property(sandbox_options_screen, "modulate:a", 0.0, 0.8).from(1.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween_hide_sandbox.tween_callback(sandbox_options_screen.hide)

func generate_random_string(length: int) -> String:
	var characters: String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
	var result: String = ""
	for i in range(length):
		var index = randi() % characters.length()
		result += characters[index]
	return result
