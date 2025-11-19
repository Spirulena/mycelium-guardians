extends Node
class_name MapRenderer

@export var cell_size : Vector2 = Vector2(64,32)
@export var map_data : MapData

func render_map():
	for child in get_children():
		child.queue_free()
	
	for y in map_data.map_data.size():
		for x in map_data.map_data[y].size():
	
			var scene: PackedScene = map_data.map_data[y][x] as PackedScene
			if scene == null:
				continue
					
			var obj: Node2D = scene.instantiate() as Node2D
			
			var iso_x = (x - y) * (cell_size.x / 2)
			var iso_y = (x + y) * (cell_size.y / 2)
			obj.position = Vector2(iso_x, iso_y)
			
			add_child(obj)

func _ready():
	#map_data.insert(4, 0, map_data.WATER)
	refresh()

func refresh():
	render_map()
