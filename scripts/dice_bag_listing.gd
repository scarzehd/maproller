extends MarginContainer

var data:DiceSet

var dice_set_menu:DiceSetMenu

func _enter_tree() -> void:
	data.name_changed.connect(change_name)
	data.color_changed.connect(change_color)
	
	change_name(data.name)
	change_color(data.color)

func _exit_tree() -> void:
	data.name_changed.disconnect(change_name)
	data.color_changed.disconnect(change_color)

func change_name(name:String):
	%DiceSetNameLabel.text = name

func change_color(color:Color):
	%DiceSetColorRect.color = color



func _on_button_pressed() -> void:
	dice_set_menu.show()
	dice_set_menu.dice_set = data
