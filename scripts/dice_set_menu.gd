extends PanelContainer
class_name DiceSetMenu

@onready var name_edit = %DiceSetName
@onready var color_picker = %ColorPickerButton
@onready var influence_world_color = %InfluenceWorldColorCheckBox

const DICE_LISTING = preload("res://scenes/dice_listing.tscn")

var dice_set:DiceSet :
	set(value):
		dice_set = value
		
		name_edit.text = value.name
		color_picker.color = value.color
		influence_world_color.button_pressed = value.influences_world_color
		
		var dice_listings = %DiceListingContainer.get_children()
		
		for dice_listing in dice_listings:
			dice_listing.queue_free()
		
		for die in value.data:
			%DiceListingContainer.add_child(create_dice_listing(die))

func remove_dice(dice_data:DiceData, listing:DiceListing) -> void:
	dice_set.data.erase(dice_data)
	listing.queue_free()

func create_dice_listing(data:DiceData) -> DiceListing:
	var dice_listing:DiceListing = DICE_LISTING.instantiate()
	dice_listing.data = data
	dice_listing.get_node("HBoxContainer/DiceListingRemoveButton").pressed.connect(remove_dice.bind(data, dice_listing))
	return dice_listing

func _on_color_picker_color_changed(color: Color) -> void:
	dice_set.color = color


func _on_dice_set_name_text_submitted(new_text: String) -> void:
	dice_set.name = new_text


func _on_close_button_pressed() -> void:
	hide()


func _on_check_box_toggled(toggled_on: bool) -> void:
	dice_set.influences_world_color = toggled_on


func _on_dice_plus_button_pressed() -> void:
	var dice_data = DiceData.new(DiceData.DiceSize.D4, 4, dice_set)
	dice_set.data.append(dice_data)
	%DiceListingContainer.add_child(create_dice_listing(dice_data))
