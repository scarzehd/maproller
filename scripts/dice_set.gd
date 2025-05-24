extends Resource
class_name DiceSet

signal name_changed(new_name:String)
signal color_changed(new_color:Color)

@export var data:Array[DiceData]

@export var name:String :
	set(value):
		name = value
		
		name_changed.emit(name)

@export var color:Color :
	set(value):
		color = value
		color_changed.emit(color)

@export var influences_world_color:bool

func _init(dice:Array[DiceData], name:String, color:Color = Color.RED, influences_world_color:bool = true) -> void:
	self.data = dice
	self.name = name
	self.color = color
	self.influences_world_color = influences_world_color
	
	for die in dice:
		die.dice_set = self

static func create_standard_set(name:String = "New Dice Set", color:Color = Color.RED) -> DiceSet:
	return new(
		[
			DiceData.new(DiceData.DiceSize.D4, 4),
			DiceData.new(DiceData.DiceSize.D6, 6),
			DiceData.new(DiceData.DiceSize.D8, 8),
			DiceData.new(DiceData.DiceSize.D10, 10),
			DiceData.new(DiceData.DiceSize.D12, 12),
			DiceData.new(DiceData.DiceSize.D20, 20)
		],
		name,
		color
	)

func create_dice() -> Array[Dice]:
	var dice:Array[Dice] = []
	
	for datum in data:
		dice.append(Dice.create(datum))
	
	return dice
