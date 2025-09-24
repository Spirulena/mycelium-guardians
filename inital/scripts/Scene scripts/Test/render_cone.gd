extends Node2D
@onready var sub_viewport_container: SubViewportContainer = $SubViewportContainer
@onready var sub_viewport: SubViewport = $SubViewportContainer/SubViewport

func save_viewport_to_png(viewport_path: String, save_path: String):
	var viewport: Viewport = get_node(viewport_path) as SubViewport
	viewport.force_redraw()  # Ensure the viewport updates its contents before capturing

	var image: Image = viewport.get_texture().get_data()
	image.flip_y()  # Image might be flipped vertically, correct it

	# Save as PNG
	var image_texture = ImageTexture.new()
	image_texture.create_from_image(image)
	image_texture.save_png(save_path)

func _ready() -> void:
	#save_viewport_to_png("SubViewportContainer/SubViewport", "res://cone.png")
	await RenderingServer.frame_post_draw
	$SubViewportContainer/SubViewport.get_texture().get_image().save_png("res://ex2.png")

