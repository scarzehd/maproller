@tool
extends ResourceFormatSaver
class_name PresetFormatSaver

func _get_recognized_extensions(resource: Resource) -> PackedStringArray:
	return PackedStringArray(["mrpreset"])

func _recognize(resource: Resource) -> bool:
	return resource is Preset

func _save(resource: Resource, path: String, flags: int) -> Error:
	var file = FileAccess.open(path, FileAccess.ModeFlags.WRITE)
	
	var dice_sets:Array[DiceSet] = resource.dice_sets
	
	for dice_set in dice_sets:
		file.store_line(":" + dice_set.name + ":" + dice_set.color.to_html(true) + ":" + ("1" if dice_set.influences_world_color else "0"))
		
		for die in dice_set.data:
			file.store_line("" + str(die.size as int) + "," + str(die.sides))
	
	file.close()
	
	return OK
