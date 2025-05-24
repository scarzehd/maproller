extends Resource
class_name Preset

@export var dice_sets:Array[DiceSet]

func _init(dice_sets:Array[DiceSet]):
	self.dice_sets = dice_sets

func get_save_strings() -> Array[String]:
	var strings:Array[String] = []
	
	for dice_set in dice_sets:
		strings.append(":" + dice_set.name + ":" + dice_set.color.to_html(true) + ":" + ("1" if dice_set.influences_world_color else "0"))
		
		for die in dice_set.data:
			strings.append("" + str(die.size as int) + "," + str(die.sides))
	
	return strings
