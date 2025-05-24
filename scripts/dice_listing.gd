extends VBoxContainer
class_name DiceListing

var data:DiceData

func _enter_tree() -> void:
	data.sides_changed.connect(sides_changed)
	data.size_changed.connect(size_changed)
	
	sides_changed(data.sides)
	size_changed(data.size)

func _exit_tree() -> void:
	data.sides_changed.disconnect(sides_changed)
	data.size_changed.disconnect(size_changed)

func sides_changed(value:int):
	%DiceSidesRange.value = value

func size_changed(value:DiceData.DiceSize):
	%DiceSizeOption.selected = value as int


func _on_dice_size_option_item_selected(index: int) -> void:
	data.size = index as DiceData.DiceSize

func _on_dice_sides_range_value_changed(value: float) -> void:
	data.sides = value
