extends Window

func _ready() -> void:
	MapProjectSettings.register_setting_listener(MapProjectSettings.EXPORT_RESOLUTION, export_resolution_changed, true)
	MapProjectSettings.register_setting_listener(MapProjectSettings.MAP_BACKGROUND_COLOR, map_background_color_changed, true)
	
	%MapBackgroundColorPickerButton.get_picker().deferred_mode = true

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action("ui_cancel"):
		_on_close_requested()

func export_resolution_changed(resolution:Vector2i) -> void:
	%ExportResolutionX.value = resolution.x
	%ExportResolutionY.value = resolution.y

func map_background_color_changed(color:Color) -> void:
	%MapBackgroundColorPickerButton.color = color

func _on_close_requested() -> void:
	hide()

func _on_export_resolution_x_value_changed(value: float) -> void:
	var resolution:Vector2i = MapProjectSettings.settings[MapProjectSettings.EXPORT_RESOLUTION]
	resolution.x = value
	MapProjectSettings.set_setting(MapProjectSettings.EXPORT_RESOLUTION, resolution)

func _on_export_resolution_y_value_changed(value: float) -> void:
	var resolution:Vector2i = MapProjectSettings.settings[MapProjectSettings.EXPORT_RESOLUTION]
	resolution.y = value
	MapProjectSettings.set_setting(MapProjectSettings.EXPORT_RESOLUTION, resolution)


func _on_map_background_color_changed(color: Color) -> void:
	MapProjectSettings.set_setting(MapProjectSettings.MAP_BACKGROUND_COLOR, color)
