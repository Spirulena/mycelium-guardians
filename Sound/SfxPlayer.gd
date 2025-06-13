class_name SfxPlayer extends Node2D

enum SFX {
	expand,
	harvest,
	place_structure,
	prune,
	recycle,
	invest_in_forest,
	generic_button_pressed,
	storage_added,
	bottom_menu_button_pressed,
	heal_tile,
	heal_structure,
	smog_acid_produce_upgrade,
	spore_tower_start_production,
	spore_tower_pause_production,
	spore_tower_un_pause_production,
	upgrade_forest_rumble,
	structure_select_absorber_radiation,
	structure_select_absorber_smog,
	structure_select_export_center,
	structure_select_storage_carbon,
	structure_select_storage_energy,
	structure_select_storage_minerals,
	structure_select_storage_water,
}

#@onready var audio_server = AudioServer
#enum SFX {expand, harvest, place_structure, prune, recycle, invest_in_forest}
var pool: Dictionary = {
	SfxPlayer.SFX.expand:  {"path": "res://Assets/sfx/expand/"},
	SfxPlayer.SFX.harvest: {"path": "res://Assets/sfx/harvest/made_02/"},
	SfxPlayer.SFX.place_structure: {"path": "res://Assets/sfx/place_structure/"},
	SfxPlayer.SFX.prune: {"path": "res://Assets/sfx/prune/"},
	SfxPlayer.SFX.invest_in_forest: {"path": "res://Assets/sfx/invest_in_forest/"},
	SfxPlayer.SFX.generic_button_pressed: {"path": "res://Assets/sfx/generic_button_pressed/"},
	SfxPlayer.SFX.storage_added: {"path": "res://Assets/sfx/storage_added/"},
	SfxPlayer.SFX.bottom_menu_button_pressed: {"path": "res://Assets/sfx/bottom_menu_button_pressed/"},
	SfxPlayer.SFX.heal_tile: {"path": "res://Assets/sfx/heal_tile/"},
	SfxPlayer.SFX.heal_structure: {"path": "res://Assets/sfx/heal_structure/"},
	SfxPlayer.SFX.smog_acid_produce_upgrade: {"path": "res://Assets/sfx/smog_acid_produce_upgrade/"},
	SfxPlayer.SFX.spore_tower_start_production: {"path": "res://Assets/sfx/spore_tower_start_production/"}, ## Or default to enum Name, that can be override here ?
	SfxPlayer.SFX.spore_tower_pause_production: {"path": "res://Assets/sfx/spore_tower_pause_production/"},
	SfxPlayer.SFX.spore_tower_un_pause_production : {"path": "res://Assets/sfx/spore_tower_un_pause_production/"},
	SfxPlayer.SFX.upgrade_forest_rumble : {"path": "res://Assets/sfx/upgrade_forest_rumble/"},
	SfxPlayer.SFX.structure_select_absorber_radiation : {"path": "res://Assets/sfx/structure_select_absorber_radiation/"},
	SfxPlayer.SFX.structure_select_absorber_smog : {"path": "res://Assets/sfx/structure_select_absorber_smog/"},
	SfxPlayer.SFX.structure_select_export_center : {"path": "res://Assets/sfx/structure_select_export_center/"},
	SfxPlayer.SFX.structure_select_storage_carbon : {"path": "res://Assets/sfx/structure_select_storage_carbon/"},
	SfxPlayer.SFX.structure_select_storage_energy : {"path": "res://Assets/sfx/structure_select_storage_energy/"},
	SfxPlayer.SFX.structure_select_storage_minerals : {"path": "res://Assets/sfx/structure_select_storage_minerals/"},
	SfxPlayer.SFX.structure_select_storage_water : {"path": "res://Assets/sfx/structure_select_storage_water/"},
}

@onready var radiation: AudioStreamPlayer = %radiation

func _ready():
	_mute_sfx_bus()
	_init_sfx_nodes()
	# Events.play_sfx_type.connect(_on_play_sfx_type)
	#Events.show_radiation_grid_heatmap.connect(_on_show_radiation_grid_heatmap)
	#Events.hide_radiation_grid_heatmap.connect(_on_hide_radiation_grid_heatmap)
	_init_radiation()
	_un_mute_sfx_bus()

func _mute_sfx_bus():
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("sfx_bus"),
		linear_to_db(0)
	)
func _un_mute_sfx_bus():
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("sfx_bus"),
		linear_to_db(1)
	)
func _init_sfx_nodes():
	# create sfx players
	for sound_type in pool.keys():
		var player = AudioStreamPlayer.new()
		if 'structure_select' in SFX.keys()[sound_type]:
			player.bus = "structure_select"
			player.max_polyphony = 1
		elif 'place_structure' in SFX.keys()[sound_type]:
			player.bus = "place_structure"
			player.max_polyphony = 1
		else:
			player.bus = "sfx"
			player.max_polyphony = 3
		var path_to_samples = pool[sound_type]["path"]
		player.stream = get_randomizer_for_path(path_to_samples, "ogg")
		pool[sound_type]["player"] = player
		add_child(player)
		player.name = SfxPlayer.SFX.keys()[sound_type]

# un-mute the sfx bus
func _on_level_loaded():
	# can wait till UI is on
	# await get_tree().create_timer(2).timeout
	_un_mute_sfx_bus()
	# var bus_name = "sfx_bus"
	# var bus_index:int = AudioServer.get_bus_index(bus_name)
	# var current_bus_volume = db_to_linear(
	# 	AudioServer.get_bus_volume_db(bus_index)
	# )
	# var tween: Tween = self.create_tween()
	# tween.tween_method(change_audio_bus_volume.bind(bus_index), current_bus_volume, 1.0, 1.0).set_ease(Tween.EASE_OUT)

func _init_radiation():
	radiation.bus = "radiation_fade"
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(radiation.bus), linear_to_db(0.0))
	radiation.play()
	# Mute a little if still on

func _on_show_radiation_grid_heatmap():
	var bus_index:int = AudioServer.get_bus_index(radiation.bus)
	var current_bus_volume = db_to_linear(
		AudioServer.get_bus_volume_db(bus_index)
	)
	var tween: Tween = self.create_tween()
	tween.tween_method(change_audio_bus_volume.bind(bus_index), current_bus_volume, 1.0, 1.0).set_ease(Tween.EASE_OUT)

func _on_hide_radiation_grid_heatmap():
	var bus_index:int = AudioServer.get_bus_index(radiation.bus)
	var current_bus_volume = db_to_linear(
		AudioServer.get_bus_volume_db(bus_index)
	)
	var tween: Tween = self.create_tween()
	tween.tween_method(change_audio_bus_volume.bind(bus_index), current_bus_volume, 0.0, 1.0).set_ease(Tween.EASE_OUT)

func change_audio_bus_volume(value: float, bus_index: int):
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))

func play_sfx_type(sfx_type):
	# print("_on_play_sfx_type - ", sfx_type)
	pool[sfx_type]["player"].play()

func get_randomizer_for_path(audio_dir: String, extension : String = "mp3"):
	var randomizer: AudioStreamRandomizer = AudioStreamRandomizer.new()
	randomizer.random_pitch = 1.0
	randomizer.random_volume_offset_db = 1.0
	var i = 0
	var dir = DirAccess.open(audio_dir)
	if dir:
		dir.list_dir_begin()
		while true:
			var file = dir.get_next()
			if file == "":
				break
			elif dir.current_is_dir():
				continue
			var path = audio_dir + file
			# print("Audio files scan '%s'" % [path])
			var dot_extension = ".%s" % extension
			if (file.get_extension() == "import" and dot_extension in file):
				# print("Got %s in %s" % [extension, file])
				# Strip ".import" extension in build, as load don't like that
				if file.get_extension() == "import":
					# print("%s removing .import" %file)
					var split = path.rsplit(".import", true, 1)
					path = split[0]
					# print("after split: [%s]" % path)
				# print("will run load('%s')" % path)
				var resource = load(path)
				# print("Loaded [%s] - %s" % [resource, file])
				if resource is AudioStream:
					# print("Add [%s] to randomizer - %s" % [resource, file])
					randomizer.add_stream(i, resource)
					i += 1
		dir.list_dir_end()
	return randomizer
