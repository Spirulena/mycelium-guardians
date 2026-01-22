extends Node
class_name MapRenderer

@export var cell_size : Vector2 = Vector2(64,32)
@export var map_data : MapData

func render_map():
	for child in get_children():
		child.queue_free()
	
	for y in range(map_data.height):
		for x in range(map_data.width):
			var scene: PackedScene = map_data.get_tile(x, y)
			if scene == null:
				continue
			
			var obj: Node2D = scene.instantiate() as Node2D
			
			var iso_x = (x - y) * (cell_size.x / 2)
			var iso_y = (x + y) * (cell_size.y / 2)
			obj.position = Vector2(iso_x, iso_y)
			
			add_child(obj)

func _ready():
	generate_map_objects()
	refresh()

func refresh():
	render_map()

func generate_map_objects():
	# grass
	map_data.generate(50, 50, map_data.GRASS)
	
	#water
	map_data.generate_patch(Vector2(10, 10), 3, map_data.WATER)
	map_data.generate_patch(Vector2(25, 25), 2, map_data.WATER)
	map_data.generate_patch(Vector2(40, 30), 3, map_data.WATER)
	map_data.generate_patch(Vector2(45, 20), 2, map_data.WATER)
	
	#cobblestone
	map_data.generate_patch(Vector2(50,50), 10, map_data.COBBLESTONE)
	map_data.generate_patch(Vector2(20, 5), 8, map_data.COBBLESTONE)
	map_data.generate_patch(Vector2(3, 35), 12, map_data.COBBLESTONE)
	map_data.generate_patch(Vector2(15, 22), 5, map_data.COBBLESTONE)
	map_data.generate_patch(Vector2(40, 20), 5, map_data.COBBLESTONE)
