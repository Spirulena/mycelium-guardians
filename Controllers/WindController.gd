class_name WindController extends Node

var msec
var _lc: LevelController

func _init():
	_lc = LevelController.get_level_controller()
	msec = 0

#func _process(delta):
	#msec += Time.get_ticks_msec()
	#if int(msec) % 60 * 500 == 0:
		#_lc.set_wind_vector(Vector2(randf_range(-0.01,0.01), randf_range(-0.01,0.01)))
		#_lc.set_wind_direction(
			#_lc.get_wind_direction().lerp(
				#_lc.get_wind_vector(), 0.0001
				#)
			#)


	#_lc.set_wind_direction(
		#_lc.get_wind_direction().lerp(
			#_lc.get_wind_vector(), 0.0001
			#)
		#)
