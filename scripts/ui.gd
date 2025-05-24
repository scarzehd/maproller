extends Control
class_name UI

static var instance:UI

const DICE_BAG_LISTING = preload("res://scenes/dice_bag_listing.tscn")

var dice_sets:Array[DiceSet]

@export var map_material:StandardMaterial3D

@export var export_viewport:SubViewport
@export var export_camera:Camera3D

@onready var dice_set_menu = %DiceSetMenu

var rolling := false

var mode := 0 :
	set(value):
		mode = value
		
		toggle_roll_state(value == 0)
		toggle_edit_state(value == 1)

#@onready var mode_menu := $MenuBar/Mode

func toggle_roll_state(value:bool):
	if value:
		%DicePanel.show()
	else:
		%DicePanel.hide()

func toggle_edit_state(value:bool): # TODO change this once edit mode is done
	if value:
		pass
	else:
		pass

func _ready() -> void:
	mode = 0

func _enter_tree() -> void:
	UI.instance = self

func _process(delta: float) -> void:
	if rolling:
		var dice = get_tree().get_nodes_in_group("dice")
		
		for die in dice:
			if die.rolling:
				return
		
		rolling = false
		update_outlines()

func update_outlines() -> void:
	var dice = get_tree().get_nodes_in_group("dice")

	
	if dice.size() <= 0:
		#map_material.set_shader_parameter("enabled", false)
		return
	
	var data_image:Image = Image.create_empty(dice.size(), 1, false, Image.FORMAT_RGBAF)
	
	var color_image:Image = Image.create_empty(dice.size(), 1, false, Image.FORMAT_RGB8)
	
	for i in range(dice.size()):
		var die := dice[i] as Dice
		
		data_image.set_pixel(i, 0, Color(die.position.x, die.position.z, die.data.dice_set.influences_world_color))
		color_image.set_pixel(i, 0, die.data.dice_set.color)
	
	var texture := ImageTexture.create_from_image(data_image)
	var color_texture := ImageTexture.create_from_image(color_image)
	
	var map_texture = await MapGenerator.render_map(texture, color_texture)
	
	map_material.albedo_texture = map_texture

func remove_dice_set(dice_set:DiceSet, dice_set_listing:Control) -> void:
	if dice_set_menu.dice_set == dice_set:
		dice_set_menu.hide()
	
	dice_set_listing.queue_free()
	
	dice_sets.erase(dice_set)

func _on_plus_button_pressed() -> void:
	var dice_set = DiceSet.create_standard_set("New Dice Set", Color.RED)
	create_dice_set_listing(dice_set)

func create_dice_set_listing(dice_set:DiceSet) -> Node:
	var dice_bag_listing = DICE_BAG_LISTING.instantiate()
	dice_sets.append(dice_set)
	dice_bag_listing.data = dice_set
	dice_bag_listing.dice_set_menu = dice_set_menu
	dice_bag_listing.get_node("HBoxContainer/CloseButton").pressed.connect(remove_dice_set.bind(dice_set, dice_bag_listing))
	%DiceBagsContainer.add_child(dice_bag_listing)
	return dice_bag_listing

func roll() -> void:
	var dice:Array[Dice] = []
	
	for dice_set in dice_sets:
		dice.append_array(dice_set.create_dice())
	
	for die in dice:
		die.hide()
		get_parent().add_child(die)
	
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	rolling = true
	
	for die in dice:
		die.show()
		die.position = Vector3(randf_range(-5, 5), 0.1, randf_range(-5, 5))
		die.roll_at(Vector3(randf_range(-5, 5), 0, randf_range(-5, 5)))

func reset() -> void:
	var dice = get_tree().get_nodes_in_group("dice")
	
	for die in dice:
		die.queue_free()
	
	await get_tree().process_frame
	update_outlines()


func _on_save_button_pressed() -> void:
	%SavePresetDialog.show()

func _on_load_button_pressed() -> void:
	%LoadPresetDialog.show()

func _on_save_dialog_file_selected(path: String) -> void:
	ResourceSaver.save(Preset.new(dice_sets), path)

func _on_load_dialog_file_selected(path: String) -> void:
	var preset:Preset = ResourceLoader.load(path)
	
	if not preset:
		return
	
	load_preset(preset)


func load_preset(preset:Preset):
	var new_dice_sets := preset.dice_sets
	
	var dice_set_listings:Array = %DiceBagsContainer.get_children()
	
	for listing in dice_set_listings:
		remove_dice_set(listing.data, listing)
	
	for dice_set in new_dice_sets:
		create_dice_set_listing(dice_set)

#func _on_mode_index_pressed(index: int) -> void:
	#if index == mode:
		#return
	#
	#mode = index
	#
	#for i in range(mode_menu.item_count):
		#mode_menu.set_item_checked(i, false)
	#
	#mode_menu.set_item_checked(index, true)


func _on_file_index_pressed(index: int) -> void:
	match index:
		0:
			%SaveMapDialog.show()
		1:
			%LoadMapDialog.show()
		2:
			%ExportMapDialog.show()


func _on_save_map_dialog_file_selected(path: String) -> void:
	var dice = get_tree().get_nodes_in_group("dice")
	
	var dice_filtered:Array[Dice] = []
	
	for die in dice: # We have to do this manually because Array.filter() always returns an Array[Variant].
		if die is Dice:
			dice_filtered.append(die as Dice)
	
	MapSaver.save_map(path, dice_filtered)



func _on_load_map_dialog_file_selected(path: String) -> void:
	load_preset(await MapSaver.load_map(path))


func _on_export_map_dialog_file_selected(path: String) -> void:
	export_image(path)

func export_image(path:String) -> void:
	
	print(export_camera.get_viewport())
	
	var dice := get_tree().get_nodes_in_group("dice")
	
	var labels:Array
	
	var label_settings := LabelSettings.new()
	
	label_settings.font_size = 40
	
	for die in dice:
		var label = die.get_node("Label").duplicate()
		
		export_viewport.add_child(label)
		
		label.position = export_camera.unproject_position(die.position) - label.size / 2
		
		var settings = label
		
		label.label_settings = label_settings
		
		labels.append(label)

	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	
	export_viewport.get_texture().get_image().save_png(path)
	
	for label in labels:
		label.queue_free()
