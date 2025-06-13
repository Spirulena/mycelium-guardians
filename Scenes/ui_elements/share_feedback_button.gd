extends Button

# Link https://forms.gle/vdDFRk31Va6Run1fA
var form_link = "https://forms.gle/vdDFRk31Va6Run1fA"
var form_link_ea = "https://forms.gle/KdFcsnRrGV2vv5wH9"

func _ready():
	# TODO: change based on EA or demo
	pressed.connect(func():
		#Events.play_sfx_type.emit(SfxPlayer.SFX.heal_structure)
		if OS.has_feature("steam_demo"):
			OS.shell_open(form_link)
		elif OS.has_feature("steam_release"):
			OS.shell_open(form_link_ea)
	)
