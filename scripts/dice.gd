extends RigidBody3D
class_name Dice

const TEMPLATE = preload("res://scenes/dice.tscn")

const D4_MESH:Mesh = preload("res://meshes/dice/dice_D4.res")
const D6_MESH:Mesh = preload("res://meshes/dice/dice_D6.res")
const D8_MESH:Mesh = preload("res://meshes/dice/dice_D8.res")
const D10_MESH:Mesh = preload("res://meshes/dice/dice_D10.res")
const D12_MESH:Mesh = preload("res://meshes/dice/dice_D12.res")
const D20_MESH:Mesh = preload("res://meshes/dice/dice_D20.res")

const D4_TEXTURE:Texture2D = preload("res://sprites/d4.png")
const D6_TEXTURE:Texture2D = preload("res://sprites/d6.png")
const D8_TEXTURE:Texture2D = preload("res://sprites/d8.png")
const D10_TEXTURE:Texture2D = preload("res://sprites/d10.png")
const D12_TEXTURE:Texture2D = preload("res://sprites/d12.png")
const D20_TEXTURE:Texture2D = preload("res://sprites/d20.png")

var rolling := false
var grace_period := false

var current_roll := 0 :
	set(value):
		current_roll = value
		$Label.text = str(value)

var data:DiceData

static func create(data:DiceData) -> Dice:
	var dice:Dice = TEMPLATE.instantiate()
	dice._create(data)
	return dice

func _create(data:DiceData):
	self.data = data
	
	var mesh := MeshInstance3D.new()
	
	match data.size:
		DiceData.DiceSize.D4:
			mesh.mesh = D4_MESH
			$Sprite3D.texture = D4_TEXTURE
		DiceData.DiceSize.D6:
			mesh.mesh = D6_MESH
			$Sprite3D.texture = D6_TEXTURE
		DiceData.DiceSize.D8:
			mesh.mesh = D8_MESH
			$Sprite3D.texture = D8_TEXTURE
		DiceData.DiceSize.D10:
			mesh.mesh = D10_MESH
			$Sprite3D.texture = D10_TEXTURE
		DiceData.DiceSize.D12:
			mesh.mesh = D12_MESH
			$Sprite3D.texture = D12_TEXTURE
		DiceData.DiceSize.D20:
			mesh.mesh = D20_MESH
			$Sprite3D.texture = D20_TEXTURE
	
	var material := StandardMaterial3D.new()
	material.albedo_color = data.dice_set.color
	
	$Sprite3D.modulate = data.dice_set.color
	
	mesh.material_override = material
	
	add_child(mesh)
	
	var collider := CollisionShape3D.new()
	collider.shape = mesh.mesh.create_convex_shape()
	add_child(collider)

func roll_at(destination:Vector3) -> void:
	apply_central_impulse(position.direction_to(destination).normalized())
	apply_torque_impulse(Vector3(randf_range(-0.5, .5), randf_range(-0.5, .5), randf_range(-0.5, .5)))
	
	start_roll()

func _process(delta: float) -> void:
	if rolling:
		roll()
	
	$Label.position = get_viewport().get_camera_3d().unproject_position(position) - $Label.size / 2

func start_roll() -> void:
	rolling = true
	grace_period = true
	$Timer.start(0.5)

func roll() -> void:
	var speed = linear_velocity.length()
	
	var chance = -pow(0.5, speed * 0.5) + 1
	
	if !grace_period and chance < 0.05:
		rolling = false
		freeze = true
		return
	
	if randf() < chance:
		current_roll = randi_range(1, data.sides)


func _on_timer_timeout() -> void:
	grace_period = false
