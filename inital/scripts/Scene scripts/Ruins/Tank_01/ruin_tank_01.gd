extends Node2D

@onready var tank = $Render01512x256
@onready var covered_sprite = $Tank02Covered01
@onready var covered_sprite_color_fade = $X2Tank04JustCoverBottomBlend


@onready var mushrooms = $AnimatedMushrooms
@onready var timer = $Timer

@export var mycelium_color = Color('93a852') #This needs to be set somewhere per level ?

func _ready():
	covered_sprite.modulate.a = 0
	covered_sprite_color_fade.modulate.a = 0
	for child in mushrooms.get_children():
		child.modulate.a = 0
	timer.timeout.connect(digest_animation)

func play_cover():
	var modulate_tween = self.create_tween()
	modulate_tween.tween_property(covered_sprite, "modulate:a", 1.0, 4.0)
	modulate_tween.parallel().tween_property(mushrooms, "modulate:a", 1.0, 4.0)
	modulate_tween.parallel().tween_property(covered_sprite_color_fade, "modulate", mycelium_color, 4.0)
	modulate_tween.tween_callback(func(): 
		var tank_tween = tank.create_tween()
		tank_tween.tween_property(tank, "modulate:a", 0, 1)
		timer.start()
		digest_animation()
		)
	# Speed should be controlled by CTRler

	# Would rather have it dissolve with noise and grandient
	var size_tween = self.create_tween()
	size_tween.tween_property(self, "scale", Vector2(0.9,0.9), 60).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	size_tween.tween_property(self, "modulate:a", 0, 10).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	# Callback should stop harvester.
	# Rather, data should drive animation of dissolve, based on how much it is digested
	# But here we have just a visual prototype
	# Would be usefull to have ref to _model of ruin. to indicate need to 

var prev_children = []

# Tween in one of the mushrooms, and hide another
func digest_animation():
	for i in range(2):
		#if is_instance_valid(prev_children):
			#tween_hide(prev_children)
		if prev_children == null or prev_children.size() < 7:
			var child = mushrooms.get_children().pick_random()
			tween_show(child)
			prev_children.append(child)
	if prev_children.size() >= 4:
		var child = prev_children.pop_front()
		tween_hide(child)

func tween_show(child):
	var tween = child.create_tween()
	tween.tween_property(child, "modulate:a", 1.0, 3.0)

func tween_hide(child):
	var tween = child.create_tween()
	#tween.tween_property(child, "modulate", Color.BLACK, 1)
	tween.tween_property(child, "modulate:a", 0, 1)
	#tween.tween_property(child, "modulate", Color.WHITE, 0.1)
