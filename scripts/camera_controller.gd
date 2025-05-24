extends Camera3D

@onready var zoom := size

var drag_start_mouse_pos := Vector2.ZERO
var drag_start_camera_pos := Vector3.ZERO
var dragging := false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("camera_zoom_in"):
		zoom *= 0.9
	
	if event.is_action_pressed("camera_zoom_out"):
		zoom *= 1.1

func _process(delta: float) -> void:
	handle_zoom(delta)
	#handle_pan(delta)
	click_and_drag()


func handle_zoom(delta: float) -> void:	
	size = lerp(size, zoom, 10 * delta)

func handle_pan(delta: float) -> void:
	var move = Input.get_vector("camera_move_left", "camera_move_right", "camera_move_up", "camera_move_down").normalized()
	
	move *= delta * size
	
	position += Vector3(move.x, 0, move.y)

func click_and_drag() -> void:
	if !dragging and Input.is_action_just_pressed("camera_pan"):
		drag_start_mouse_pos = get_viewport().get_mouse_position()
		drag_start_camera_pos = position
		dragging = true
	
	if dragging and Input.is_action_just_released("camera_pan"):
		dragging = false
	
	if dragging:
		var move = get_viewport().get_mouse_position() - drag_start_mouse_pos
		move /= Vector2(get_viewport().size.y / size, get_viewport().size.y / size) # The orthographic size is the width, not the height.
		position = drag_start_camera_pos - Vector3(move.x, 0, move.y)
