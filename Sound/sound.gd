class_name MusicPlayer extends Node2D

@onready var ambient: AudioStreamPlayer = %Ambient
@onready var chords: AudioStreamPlayer = %Chords
@onready var music: AudioStreamPlayer = %Music

#@onready var AudioServer = AudioServer
var chords_timer: Timer

func _ready():
	chords_timer = Timer.new()
	chords_timer.wait_time = 3.0  # Set the timer to tick every second
	chords_timer.autostart = false # TODO: make it optional
	# So we can add music component but not start playing if not requested in sandbox
	chords_timer.timeout.connect(_on_timer_timeout)
	add_child(chords_timer)
	chords.finished.connect(_chords_finished)

	#Events.play_next_music_track.connect(_play_next)
	#Events.play_previous_music_track.connect(_play_previous)
	randomize()
	_init_music_tracks()

func fade_out_ambient(time: float):
	# # fade out, stop ambient, then reset volume
	pass
	var bus_index:int = AudioServer.get_bus_index("ambience")
	var current_bus_volume = db_to_linear(
		AudioServer.get_bus_volume_db(bus_index)
	)
	var tween: Tween = self.create_tween()
	tween.tween_method(change_audio_bus_volume.bind(bus_index), current_bus_volume, 0.0, time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween.tween_callback(ambient.stop)
	tween.tween_callback(AudioServer.set_bus_volume_db.bind(bus_index, linear_to_db(current_bus_volume)))

func change_audio_bus_volume(value: float, bus_index: int):
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))

func start_random_chords():
	chords_timer.start()

func _chords_finished():
	chords_timer.wait_time = randf_range(60*0.7, 60*2.5)
	chords_timer.start()

func _on_timer_timeout():
	chords_timer.stop()
	chords.play()
	

func _init_music_tracks():
	# print("music track init")
	if music.stream == null:
		music.stream = get_randomizer_for_path("res://Assets/music/", "mp3")
	# on level loaded
	# play some kind of entry ?
	ambient.play()
	ambient.finished.connect(_on_ambient_finished)

	music.finished.connect(_on_track_finished)

func _on_ambient_finished():
	#music.play()
	ambient.play()

# TODO: for now keep ambient playing and add some cords on top of that
# TODO: trump random cords with cords indicating some changes in gameplay
# on deficit some,
# on 1st structure, 5structures
# on 1st grass
# also the more nature the more sounds
# grass adds more swash
# for cords consider Plantasia - Rhapsody in green
# what is the sound of decomposition of ruins ?

func _on_track_finished():
	ambient.play()

func get_randomizer_for_path(audio_dir: String, extension : String = "mp3"):
	var randomizer = AudioStreamRandomizer.new()
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
				# TODO: load threaded
				var resource = load(path)
				# print("Loaded [%s] - %s" % [resource, file])
				if resource is AudioStream:
					# print("Add [%s] to randomizer - %s" % [resource, file])
					randomizer.add_stream(i, resource)
					i += 1
		dir.list_dir_end()
	return randomizer

func _play_next():
	#print_debug()
	# could save, get_stream, then set_stream.
	if music.playing:
		music.stop()
		music.play()

func _play_previous():
	#print_debug()
	# could save the current index
	if music.playing:
		music.stop()
		music.play()
