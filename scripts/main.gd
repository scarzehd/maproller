extends Node3D

@export var map_material:StandardMaterial3D

func _ready() -> void:
	MapProjectSettings.register_setting_listener(MapProjectSettings.EXPORT_RESOLUTION, func(resolution:Vector2i): %ExportViewport.size = resolution, true)
	MapProjectSettings.register_setting_listener(MapProjectSettings.MAP_BACKGROUND_COLOR, update_map_background_color, true)

func update_map_background_color(color:Color):
	var texture = map_material.albedo_texture
	if texture is not GradientTexture1D:
		return
	var gradient:Gradient = texture.gradient
	gradient.colors = [color]
