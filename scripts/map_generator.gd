extends SubViewport

@export var map_material:ShaderMaterial
@onready var plane := %Plane

func render_map(positions:ImageTexture, colors:ImageTexture) -> Texture:
	map_material.set_shader_parameter("positions", positions)
	map_material.set_shader_parameter("colors", colors)
	
	render_target_update_mode = SubViewport.UPDATE_ONCE
	
	await RenderingServer.frame_post_draw
	
	var texture = ImageTexture.create_from_image(get_texture().get_image())
	
	return texture
