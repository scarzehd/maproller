extends Node

# Do not modify this directly
var settings:Dictionary[StringName, Variant] = {
	EXPORT_RESOLUTION: Vector2i(4000, 4000),
	MAP_BACKGROUND_COLOR: Color(0.0, 0.392, 1.0)
}

const EXPORT_RESOLUTION:StringName = &"export_resolution"
const MAP_BACKGROUND_COLOR:StringName = &"map_background_color"

signal setting_changed(setting:StringName, value:Variant)

func set_setting(setting:StringName, value:Variant) -> void:
	settings[setting] = value
	setting_changed.emit(setting, value)

func register_setting_listener(setting:StringName, listener:Callable, update_now:bool = false) -> Callable:
	var callable = func(setting_changed:StringName, value:Variant):
		if setting_changed == setting:
			listener.call(value)
	setting_changed.connect(callable)
	
	if update_now:
		listener.call(settings[setting])
	
	return callable
