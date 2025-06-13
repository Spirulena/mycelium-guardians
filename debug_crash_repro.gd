extends Resource
class_name SoilDebug

## The grid's rows and columns.
@export var size := Vector2i(40, 40)
@export var all_tile_indexes: Array # = range(size.x * size.y)

# TODO: scene use loaded resource where size of all_tile_indexes == 0
# TODO: scene to call delayed_init in _ready
func delayed_init():
	all_tile_indexes = range( size.x * size.y )
	# debug point on pass, then hover over all_tiles_indexes
	pass
	# also here
	all_tile_indexes.resize(size.x * size.y )
	# TODO: try below as break point and hover when filled
	# after filled does not crash editor
	all_tile_indexes.fill(0)


	# Soil delayed init start: 9597 - 9.597
	# At: res://World/Soil/soil_custom_resource.gd:262:delayed_init()
 
#  ================================================================
#  handle_crash: Program crashed with signal 11
#  Engine version: Godot Engine v4.2.beta2.official (f8818f85e6c43cdf1277e8ae85eba19ca0a003b0)
#  Dumping the backtrace. Please include this when reporting the bug to the project developer.
#  [1] /lib/x86_64-linux-gnu/libc.so.6(+0x42520) [0x7f38c2242520] (??:0)
#  [2] /lib/x86_64-linux-gnu/libnvidia-glcore.so.470.199.02(+0xf5971b) [0x7f38a6d5971b] (??:0)
#  [3] /lib/x86_64-linux-gnu/libnvidia-glcore.so.470.199.02(+0xf5b8d2) [0x7f38a6d5b8d2] (??:0)
#  [4] /lib/x86_64-linux-gnu/libnvidia-glcore.so.470.199.02(+0xf52167) [0x7f38a6d52167] (??:0)
#  [5] /lib/x86_64-linux-gnu/libnvidia-glcore.so.470.199.02(+0xf61b46) [0x7f38a6d61b46] (??:0)
#  [6] /lib/x86_64-linux-gnu/libnvidia-glcore.so.470.199.02(+0xdc2033) [0x7f38a6bc2033] (??:0)
#  [7] /lib/x86_64-linux-gnu/libnvidia-glcore.so.470.199.02(+0xf27f17) [0x7f38a6d27f17] (??:0)
#  [8] /lib/x86_64-linux-gnu/libnvidia-glcore.so.470.199.02(+0xf06da1) [0x7f38a6d06da1] (??:0)
#  [9] /lib/x86_64-linux-gnu/libnvidia-glcore.so.470.199.02(+0x11808d8) [0x7f38a6f808d8] (??:0)
#  [10] /lib/x86_64-linux-gnu/libnvidia-glcore.so.470.199.02(+0x118268e) [0x7f38a6f8268e] (??:0)
#  [11] /lib/x86_64-linux-gnu/libnvidia-glcore.so.470.199.02(+0x1178274) [0x7f38a6f78274] (??:0)
#  [12] /lib/x86_64-linux-gnu/libnvidia-glcore.so.470.199.02(+0x1255ad3) [0x7f38a7055ad3] (??:0)
#  [13] /lib/x86_64-linux-gnu/libGLX_nvidia.so.0(+0xa51ef) [0x7f38a88a51ef] (??:0)
#  [14] /home/magic/.local/bin/Godot_v4.2-beta2_linux.x86_64() [0x10680da] (??:0)
#  [15] /home/magic/.local/bin/Godot_v4.2-beta2_linux.x86_64() [0x106854d] (??:0)
#  [16] /home/magic/.local/bin/Godot_v4.2-beta2_linux.x86_64() [0x31d5905] (??:0)
#  [17] /home/magic/.local/bin/Godot_v4.2-beta2_linux.x86_64() [0x514d45] (??:0)
#  [18] /home/magic/.local/bin/Godot_v4.2-beta2_linux.x86_64() [0x450d3f] (??:0)
#  [19] /lib/x86_64-linux-gnu/libc.so.6(+0x29d90) [0x7f38c2229d90] (??:0)
#  [20] /lib/x86_64-linux-gnu/libc.so.6(__libc_start_main+0x80) [0x7f38c2229e40] (??:0)
#  [21] /home/magic/.local/bin/Godot_v4.2-beta2_linux.x86_64() [0x46447e] (??:0)
#  -- END OF BACKTRACE --
#  ================================================================
 