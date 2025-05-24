@tool
extends ResourceFormatLoader
class_name PresetFormatLoader

func _get_recognized_extensions() -> PackedStringArray:
	return PackedStringArray(["mrpreset"])

func _get_resource_script_class(path: String) -> String:
	return "Preset"

func _get_resource_type(path: String) -> String:
	return "Resource"

func _handles_type(type: StringName) -> bool:
	return ClassDB.is_parent_class(type, "Resource")

func _load(path: String, original_path: String, use_sub_threads: bool, cache_mode: int) -> Variant:
	var file = FileAccess.open(path, FileAccess.READ)
	
	if not file:
		return FileAccess.get_open_error()
	
	var lines = file.get_as_text().split("\n", false)
	
	var dice_sets:Array[DiceSet] = []
	
	var current_dice:Array[DiceData]
	var dice_set_name = ""
	var dice_set_color:Color = Color.WHITE
	var dice_set_influences_world_color = true
	
	for line in lines:
		if line[0] == ":":
			if current_dice.size() > 0: # Create the previous set if this isn't the first
				dice_sets.append(DiceSet.new(current_dice, dice_set_name, dice_set_color, dice_set_influences_world_color))
			
			var data = line.split(":", false)
			dice_set_name = data[0]
			dice_set_color = Color(data[1])
			dice_set_influences_world_color = true if data[2] == "1" else false
			current_dice = []
		else:
			var data = line.split(",")
			current_dice.append(DiceData.new((data[0] as int) as DiceData.DiceSize, data[1] as int))
	
	dice_sets.append(DiceSet.new(current_dice, dice_set_name, dice_set_color, dice_set_influences_world_color)) # The last one won't get covered by the loop
	
	return Preset.new(dice_sets)
