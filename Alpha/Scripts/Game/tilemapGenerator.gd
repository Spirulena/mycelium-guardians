extends TileMap

var center = Vector2i(-1, 0)
var radius = 10
var outline_thickness = 2

var fill_atlas = Vector2i(0, 0)
var outline_atlas = Vector2i(0, 1)

var iso_up := Vector2i(-1, -1)

@export var ground_layer: TileMapLayer
@export var obstacle_Layer: TileMapLayer

func _ready() -> void:
	for x in range(center.x - radius - outline_thickness, center.x + radius + outline_thickness + 1):
	
		for y in range(center.y - radius - outline_thickness, center.y + radius + outline_thickness + 1):
			
			var cell = Vector2i(x, y)
			var distance = center.distance_to(cell)
			
			if distance <= radius:
				ground_layer.set_cell(cell, 0, fill_atlas)
				
			elif distance <= radius + outline_thickness:
				ground_layer.set_cell(cell, 0, outline_atlas)
	
	create_pillar(Vector2i(5, 5))
	create_pillar(Vector2i(1, 2))

func create_pillar(start: Vector2i) -> void:
	obstacle_Layer.set_cell(start, 0, Vector2i(6, 14))
	obstacle_Layer.set_cell(start + iso_up * 1, 0, Vector2i(6, 13))
	obstacle_Layer.set_cell(start + iso_up * 2, 0, Vector2i(6, 12))
