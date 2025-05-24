extends Resource
class_name DiceData

signal sides_changed(sides:int)
signal size_changed(size:DiceSize)

@export var sides:int :
	set(value):
		sides = value
		sides_changed.emit(value)

@export var size:DiceSize : 
	set(value):
		size = value
		size_changed.emit(value)

var dice_set:DiceSet

enum DiceSize {
	D4,
	D6,
	D8,
	D10,
	D12,
	D20
}

func _init(size:DiceSize = DiceSize.D4, sides:int = 4, dice_set:DiceSet = null) -> void:
	self.size = size
	self.sides = sides
	self.dice_set = dice_set
