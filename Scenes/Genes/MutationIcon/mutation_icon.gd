extends Node2D
@export var button: TextureButton
@export var label: Label
@export var panel: Panel

@export_category("Alt panel")
@export var alt_label: Label
@export var alt_label_color: RichTextLabel
@export var alt_panel: Panel

@export_category("decide")
@export var decide_panel: Panel
@export var decide_confirm: TextureButton
@export var decide_trash: TextureButton

# call up ?
# pass down the data about mutation, so we can set label
@onready var t: Tween
@onready var _model: BuildingObject

func _ready() -> void:
	t = get_tree().create_tween()
	t.set_parallel(false).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	t.tween_property(self, "scale:x", 1.2, 0.4).from(1)
	t.tween_property(self, "scale:x", 1, 0.2)
	t.set_loops(2)
	button.mouse_entered.connect(_on_button_hover)
	button.pressed.connect(pressed)
	button.mouse_exited.connect(_on_button_mouse_exited)

	panel.visible = false
	alt_panel.visible = false
	decide_panel.visible = false

func calc_change(old: float, new: float) -> float:
	return (new - old) / old * 100

func change_color(change) -> String:
	if change < 0:
		return "red"
	else:
		return "green"

func format_percent_with_sign(val: float) -> String:
	return "%s%d%%" % [Utils.get_plus_sign_string(val), val]

func set_alt_label():
	# TODO: compute change, infore mutation factor thing
	# Need to compute change between Global and current value
	var mutation: String = ""
	if _model.mutation:
		mutation = " Mutation %s" % _model.mutation_id
	var generation_i: String = "Generation #%d%s" % [_model.base_generation, mutation]
	var decay_change = float(calc_change(Global.gene_base_decay_time, _model.base_decay_time))
	var decay_change_str = format_percent_with_sign(decay_change)
	# TODO: add color + negative positive
	var decay:String
	decay =      "Decay                | (%0.2fs) -> (%0.2fs) | [color=%s]Δ%s[/color]" % [Global.gene_base_decay_time, _model.base_decay_time, change_color(decay_change), decay_change_str]
	var smog = calc_change(Global.gene_base_smog_change, _model.base_smog_change)
	var smog_str: String = format_percent_with_sign(smog)
	var smog_line =   "Smog change  | (%0.3f/s) -> (%0.3f/s) | [color=%s]Δ%s[/color]" % [Global.gene_base_smog_change, _model.base_smog_change, change_color(smog), smog_str]
	var growth_change: = calc_change(Global.gene_base_growth_factor, _model.base_growth_speed_factor)
	var growth_change_str: = format_percent_with_sign(growth_change)
	var growth_line = "Growth speed | (%d%%) -> (%d%%) | [color=%s]Δ%s[/color]" % [int(Global.gene_base_growth_factor*100), int(_model.base_growth_speed_factor*100), change_color(growth_change), growth_change_str]

	alt_label.text = "%s\n%s\n%s\n%s" % [generation_i, decay, smog_line, growth_line]
	alt_label.hide()
	# TODO: RTF
	alt_label_color.text = alt_label.text

func set_label():
	label.text = "Decay: %0.2fs - mutation: %d%%" % [_model.base_decay_time, int(_model.mutation_decay_time_factor*100)]
	var smog_line = "Smog change: %0.3f/s - mutation: %d%%" % [_model.base_smog_change, int(_model.mutation_smog_change_factor*100)]
	var growth_line = "Growth speed: %d%% - mutation: %d%%" % [int(_model.base_growth_speed_factor*100), int(_model.mutation_growth_speed_factor*100)]
	label.text = "%s\n%s\n%s" % [label.text, smog_line, growth_line]

func _on_button_mouse_exited():
	#self.scale = old_scale
	#get_tree().paused = false
	#panel.visible = false
	if mutation_opened:
		return
	alt_panel.visible = false

var old_scale: Vector2
func _on_button_hover():
	# scale to 1.0
	old_scale = self.scale
	self.scale = Vector2.ONE
	print_debug("GENE: show stats of mutation")
	#set_label()
	set_alt_label()
	#panel.visible = true
	alt_panel.visible = true
	#get_tree().paused = true


var mutation_opened: bool = false
func pressed():
	mutation_opened = true
	# show confirm , discard buttons
	alt_panel.show()
	decide_panel.show()
	decide_confirm.pressed.connect(confirmed)
	decide_trash.pressed.connect(trash)

func confirmed():
	# apply mutation
	_model.apply_mutation_as_base()

	print_debug("GENE: Mutation button pressed")

	# do new tween animation
	var nt: Tween = get_tree().create_tween()
	nt.tween_property(self, "scale", Vector2(1.2, 1.2), 0.15)
	nt.tween_property(self, "modulate:a", 0.0, 0.1).set_delay(0.05).set_ease(Tween.EASE_IN_OUT)
	nt.tween_callback(button_pressed_call_up)
	pass
	# pause game and allow player to read and choose
	# show selection
	# actions: replace as default, discard / ignore, save to pool (use later)

func trash():
	queue_free()

func button_pressed_call_up():
	print_debug("GENE: apply mutations")
	# show window.
	queue_free()
