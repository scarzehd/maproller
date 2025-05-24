class_name MapSaver

# TODO this whole system needs error handling

static func save_map(path:String, dice:Array[Dice]) -> void:
	# It's necessary to do this because it's possible for the user to delete the dice set while the die still exists
	var data:Dictionary[DiceSet, Array] = {}
	for die in dice:
		if not data.has(die.data.dice_set):
			data[die.data.dice_set] = []
		data[die.data.dice_set].append(die)
	
	var file := FileAccess.open(path, FileAccess.WRITE)
	
	for i in range(data.keys().size()):
		var dice_set = data.keys()[i]
		file.store_line(":" + dice_set.name + ":" + dice_set.color.to_html(true) + ":" + ("1" if dice_set.influences_world_color else "0"))
		
		for die in data[dice_set]:
			file.store_line("" + str(die.data.size as int) + "," + str(die.data.sides) + "," + str(die.current_roll) + "," + str(die.position.x) + "," + str(die.position.z))
	
	file.close()

static func load_map(path:String) -> Preset:
	var existing = UI.instance.get_tree().get_nodes_in_group("dice")
	
	for dice in existing:
		dice.queue_free()
	
	await UI.instance.get_tree().process_frame
	
	var file = FileAccess.open(path, FileAccess.READ)
	
	if not file:
		push_error(FileAccess.get_open_error())
	
	var lines = file.get_as_text().split("\n", false)
	
	var dice_sets:Array[DiceSet] = []
	
	var current_dice:Array[DiceData]
	var dice_set_name = ""
	var dice_set_color:Color = Color.WHITE
	var dice_set_influences_world_color = true
	
	var dice_positions:Dictionary[DiceData, Vector3]
	var dice_rolls:Dictionary[DiceData, int]
	
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
			var dice_data = DiceData.new((data[0] as int) as DiceData.DiceSize, data[1] as int)
			current_dice.append(dice_data)
			
			dice_rolls[dice_data] = data[2] as int
			dice_positions[dice_data] = Vector3(data[3] as float, 1, data[4] as float)
	
	dice_sets.append(DiceSet.new(current_dice, dice_set_name, dice_set_color)) # The last one won't get covered by the loop
	
	# This needs to be done separately because the dice data needs a reference to the dice set
	# Which can't be created until after all the dice data are created
	for dice_set in dice_sets:
		for dice_data in dice_set.data:
			var die := Dice.create(dice_data)
			die.current_roll = dice_rolls[dice_data]
			die.position = dice_positions[dice_data]
			die.freeze = true
			UI.instance.get_parent().add_child(die)
	
	UI.instance.update_outlines()
	
	return Preset.new(dice_sets)
