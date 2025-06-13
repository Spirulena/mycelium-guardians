extends Node2D

@onready var fur_player = $AnimationPlayer
@onready var circle = $Circle
@onready var total_decomposition = $TotalDecomposition
@onready var current_extraction = $CurrentExtraction


@export var mycelium_color = Color('93a852') #This needs to be set somewhere per level ?
@export var ruin_text: String


func _ready():
	total_decomposition.modulate.a = 0
	current_extraction.modulate.a = 0
	pass

func play_cover():
	fur_player.play("ShowFur_Black_and_White")
	circle.play("default")

	# Mock timers of extraction
	total_decomposition.modulate.a = 255
	current_extraction.modulate.a = 255

	var total = self.create_tween()
	total.tween_property(total_decomposition, "value", 100, 300)
	var current = self.create_tween()
	current.tween_property(current_extraction, "value", 100, 5)
	current.tween_property(current_extraction, "value", 0, 0.1)
	current.set_loops()

	fur_player.animation_finished.connect(func(anim_name):
		fur_player.play("Extracting_Loop")
		)

func die():
	fur_player.play("FadeOut")
