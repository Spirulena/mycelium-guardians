class_name  MainMenu extends Control

@onready var start_button: Button = %StartButton
@onready var sandbox_button: Button = %SandboxButton
@onready var tutorial_button: Button = %TutorialButton

@onready var loading_label = %loading_label

@onready var help_button = %HelpButton

@onready var arrows: Array = [%"1", %"2", %"3", %"4", %Journey_Arrow, %Elements_Arrow]

# Grime
@onready var grime = $VisibilityContainer/BackgroundContainer/Grime
var grime_rotation_speed: Dictionary
@onready var debug = $VisibilityContainer/RightMenuMargin/MenuVBoxContainer/Debug

# discord
@onready var discord_texture_button = $VisibilityContainer/Socials/HBoxContainer/Discord_TextureButton
var discord_invite_link = "https://discord.gg/epJQYRjVgg"


# patreon
@onready var patreon_texture_button: TextureButton = $VisibilityContainer/Socials/HBoxContainer/Patreon_TextureButton
var patreon_link = "https://www.patreon.com/MyceliumGuardians"
# version
@onready var version_label = %VersionLabel

# credits
@onready var credits_button = $VisibilityContainer/RightMenuMargin/MenuVBoxContainer/CreditsButton
@onready var credits = $VisibilityContainer/Credits
@onready var credit_back = $VisibilityContainer/Credits/credit_back

signal credits_button_pressed
signal start_button_pressed
signal sandbox_button_pressed
signal tutorial_button_pressed
signal debug_button_pressed
signal discord_button_pressed
signal help_button_pressed
signal journey_button_pressed
signal elements_button_pressed

@onready var demo_disclaimer: Control = %DemoDisclaimer
@onready var menu_story_tutorial: HBoxContainer = %MenuStoryTutorial
@onready var menu_sandbox: HBoxContainer = %MenuSandbox
@onready var disclaimer: RichTextLabel = %disclaimer

@onready var menu_journey: HBoxContainer = %MenuJourney
@onready var journey_arrow: Label = %Journey_Arrow
@onready var journey_button: Button = %JourneyButton

@onready var menu_elements: HBoxContainer = %MenuElements
@onready var elements_arrow: Label = %Elements_Arrow
@onready var elements_button: Button = %ElementsButton


func _ready():
	#Hide menu entries
	menu_sandbox.hide()
	demo_disclaimer.hide()
	start_button.hide()
	menu_story_tutorial.hide()
	menu_journey.hide()
	menu_elements.hide()


	if OS.has_feature("steam_demo"):
		demo_disclaimer.show()
		menu_story_tutorial.show()
		#start_button.show()
	if OS.has_feature("steam_release"):
		disclaimer.text = "Welcome to the early access phase of our game! As we cultivate and refine our world, expect significant developments in gameplay, mechanics, art, and sound. Enjoy exploring this growing landscape, and thank you for being part of our community's journey. Your support is invaluable. Mushlove!"
		demo_disclaimer.show()
		menu_story_tutorial.show()
		menu_sandbox.show()
		menu_elements.show()

	if OS.has_feature("editor"):
		##disclaimer.text = "Welcome to the early access phase of our game! As we cultivate and refine our world, expect significant developments in gameplay, mechanics, art, and sound. Enjoy exploring this growing landscape, and thank you for being part of our community's journey. Your support is invaluable. Mushlove!"
		#demo_disclaimer.show()
		##start_button.show()
		menu_story_tutorial.show()
		menu_sandbox.show()
		##menu_journey.show()
		menu_elements.show()
	if OS.has_feature("steam_dev"):
		menu_story_tutorial.show()
		menu_sandbox.show()
		menu_elements.show()

	debug.pressed.connect(func(): debug_button_pressed.emit())

	loading_label.hide()
	start_button.pressed.connect(_on_start_button_pressed)
	sandbox_button.pressed.connect(_on_sandbox_button_pressed)
	tutorial_button.pressed.connect(_on_tutorial_button_pressed)
	help_button.pressed.connect(_on_help_pressed)
	journey_button.pressed.connect(_on_journey_button_pressed)
	elements_button.pressed.connect(_on_elements_button_pressed)
	%ExitButton.pressed.connect(func(): get_tree().quit())

	for child in arrows:
		child.hide()
	grime_rotation_speed = {}
	for child in grime.get_children():
		grime_rotation_speed[child] = randf_range(2, 4)

	discord_texture_button.pressed.connect(func():
		OS.shell_open(discord_invite_link)
	)
	patreon_texture_button.pressed.connect(func():
		OS.shell_open(patreon_link)
	)

	# Update version label
#	version_label.text = get_version_from_file()

	# credits
	credits.hide()
	credits_button.pressed.connect(func(): credits.show())
	credit_back.pressed.connect(func(): credits.hide())
	visibility_changed.connect(_on_visibility_changed)

func _on_visibility_changed():
	set_process(visible)

func _input(event):
	if (event.is_pressed() and credits.visible) or (event is InputEventMouseButton and credits.visible):
		credits.hide()
	if event.is_action_pressed("game_ui_esc"):
		if credits.visible:
			credits.hide()

func get_version_from_file():
	var file = FileAccess.open("res://version.txt", FileAccess.READ)
# 	var content = file.get_as_text()
#	return content

func _on_help_pressed():
	help_button_pressed.emit()

func _on_journey_button_pressed():
	journey_button_pressed.emit()

func _on_elements_button_pressed():
	elements_button_pressed.emit()

func _on_sandbox_button_pressed():
	sandbox_button_pressed.emit()

func _on_tutorial_button_pressed():
	tutorial_button_pressed.emit()

func _on_start_button_pressed():
	#loading_label.show()
	start_button_pressed.emit()

func _process(delta):
	if not visible:
		return
	# $"VisibilityContainer/StartButton/5".visible = %StartButton.is_hovered()
	arrows[0].visible = %TutorialButton.is_hovered()
	arrows[1].visible = %SandboxButton.is_hovered()
	arrows[2].visible = %OptionsButton.is_hovered()
	arrows[3].visible = %HelpButton.is_hovered()
	arrows[4].visible = journey_button.is_hovered()
	arrows[5].visible = elements_button.is_hovered()

	# Grime animation
	for child in grime.get_children():
		child.rotate(deg_to_rad(grime_rotation_speed[child]) * delta)
