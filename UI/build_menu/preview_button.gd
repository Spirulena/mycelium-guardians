class_name  StructurePreviewButton extends Control

@export var resource_icons: ResourceIcons

@export var minatures: Array[Texture2D]
#
	#Missing = -1,
#0	#Storage_Water,
#1	#Storage_Energy,
#2	#Storage_Minerals,
#3	#Storage_Carbon,
#4	#Export_Center,# just for now, will change to export flag
#5	#Absorber_Radiation,
#6	#Absorber_Smog,

#7	#Emitter_Spore,
#8	#History_Apartment_1,
#9	#Techno_flat_panel,
#10	#Base,

signal pressed
signal hover_entered(id)
signal hover_exited(id)

@onready var texture_button: TextureButton = %TextureButton
@onready var name_label: Label = %NameLabel
@onready var out_icon: TextureRect = %OutIcon


var text: String
var id: int
var resource_out_id: int

func _ready() -> void:
	texture_button.pressed.connect(func(): pressed.emit())
	name_label.text = text
	# if that is smog absorber
	if id == 6:
		texture_button.modulate = Global.gene_base_color
	texture_button.texture_normal = minatures[id]
	texture_button.tooltip_text = tooltip_text

	texture_button.mouse_entered.connect(_on_mouse_entered_button)
	texture_button.mouse_exited.connect(_on_mouse_exited_button)

	out_icon.texture = resource_icons.icons_80px_array[resource_out_id]
	visibility_changed.connect(_on_visibility_changed)

	# or connect to texture button
	texture_button.mouse_entered.connect(_on_mouse_entered)
	texture_button.mouse_exited.connect(_on_mouse_exited)

# can also handle focus change
func _on_mouse_entered():
	if id == 6:
		hover_entered.emit(id)

func _on_mouse_exited():
	if id == 6:
		hover_exited.emit(id)

func _on_visibility_changed():
	# update in case the data changed
	if visible:
		if id == 6:
			texture_button.modulate = Global.gene_base_color

func _on_mouse_entered_button():

	if id == 6:
		texture_button.modulate = Global.gene_base_color
	texture_button.scale = Vector2(0.93, 0.93)
	#var s_tween: Tween = self.create_tween()
	#s_tween.tween_property(texture_button, "scale", Vector2(1.1, 1.1), 0.12).from(0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)

func _on_mouse_exited_button():
	texture_button.scale = Vector2(1, 1)
