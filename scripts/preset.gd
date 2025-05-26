extends Resource
class_name Preset

@export var dice_sets:Array[DiceSet]

func _init(dice_sets:Array[DiceSet] = []):
	self.dice_sets = dice_sets
